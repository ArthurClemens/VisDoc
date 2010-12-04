# See bottom of file for license and copyright information

package VisDoc;

use strict;
use warnings;
use utf8;
use File::Spec;
use File::Slurp qw( slurp write_file );
use File::Path;
use File::Copy;
use File::Find;
use File::stat;
use XML::TreePP;
use XML::Writer;
use Foswiki::Plugins::FreeMarkerPlugin::FreeMarkerParser;
use VisDoc::FileParser;
use VisDoc::FileData;
use VisDoc::OutputFormatter;
use VisDoc::XMLOutputFormatterIndexPage;
use VisDoc::XMLOutputFormatterToc;
use VisDoc::XMLOutputFormatterAllPackages;
use VisDoc::XMLOutputFormatterAllClasses;
use VisDoc::XMLOutputFormatterAllMethods;
use VisDoc::XMLOutputFormatterAllConstants;
use VisDoc::XMLOutputFormatterAllProperties;
use VisDoc::XMLOutputFormatterAllDeprecated;
use VisDoc::Defaults;
use VisDoc::HashUtils;
use VisDoc::PostParser;
use VisDoc::Logger;

my $VERSION = '3.0';

=pod

StaticMethod readFile($path) -> $text

Utility method. Returns the file contents of file at path $inFilePath.

=cut

sub readFile {
    my ($inFilePath) = @_;

    my ($exists) = stat($inFilePath);
    if ( !$exists ) {
        return '';
    }

    my $text = slurp( $inFilePath, binmode => ':utf8', err_mode => 'carp' );
    if ( !$text ) {
        return '';
    }
    return $text;
}

=pod

StaticMethod parseText( $text, $language ) -> $fileData

- param $language: optional

=cut

sub parseText {
    my ( $inText, $inLanguage ) = @_;

    my @texts = ($inText);
    return parseTexts( \@texts, $inLanguage )->[0];
}

=pod

parseTexts( \@texts, $language ) -> \@fileData

- param $language: optional

=cut

sub parseTexts {
    my ( $inTexts, $inLanguage ) = @_;

    my $collectiveFileData;
    foreach my $text ( @{$inTexts} ) {
        my $fileParser = VisDoc::FileParser->new();
        push @{$collectiveFileData},
          $fileParser->parseText( $text, $inLanguage );
    }
    return VisDoc::PostParser::process($collectiveFileData);
}

=pod

StaticMethod parseFile( $file, $language ) -> $fileData

- param $language: optional

=cut

sub parseFile {
    my ( $inPath, $inLanguage ) = @_;

    my @files = ($inPath);
    return parseFiles( \@files, $inLanguage )->[0];
}

=pod

parseFiles( \@files, $language ) -> \@fileData

- param $language: optional

=cut

sub parseFiles {
    my ( $inFiles, $inLanguage, $inPreferences ) = @_;

    my $collectiveFileData;
    foreach my $file ( @{$inFiles} ) {

        # check if file exists
        next unless -e $file;
        my $fileParser = VisDoc::FileParser->new();
        my $fileData = $fileParser->parseFile( $file, $inLanguage );
        if ( defined $fileData ) {
            push @{$collectiveFileData}, $fileData;
            VisDoc::Logger::logParsedFile($file);
        }
    }
    return VisDoc::PostParser::process( $collectiveFileData, $inPreferences );
}

=pod

StaticMethod validateFile( $file ) -> {valid => $bool, modificationDate => $date, language => $language }

File must exist.

=cut

sub validateFile {
    my ($inPath) = @_;

    my $fileParser = VisDoc::FileParser->new();
    my ( $fileData, $fileText ) = $fileParser->getFileData( $inPath, undef );

    # crude validity check: if a language is found we assume it is valid
    my $valid = defined $fileData->{language};

    return {
        valid            => $valid,
        modificationDate => $fileData->{modificationDate},
        language         => $fileData->{language}
    };
}

=pod

StaticMethod writeData ($directory, $collectiveFileData, \%preferences) -> ($index, \@htmlDocFileNames, \@htmlSupportingFileNames)

TOCs:

index.html
	= frameset
	as2: no packages => 
	as3, java: packages => toc-frame.html

toc-frame.html
	= frameset, loads: overview-frame.html and empty-frame.html

=cut

sub writeData {
    my ( $inDocDirectory, $inCollectiveFileData, $inPreferences ) = @_;

    my $dirInfo = _createWriteDirectories( $inDocDirectory, $inPreferences );
    my $cssFiles = _copyCss( $dirInfo->{dir}->{css}, $inPreferences );
	$inPreferences->{cssFiles} = $cssFiles;
    my $jsFiles = _copyJs( $dirInfo->{dir}->{js}, $inPreferences );
	$inPreferences->{jsFiles} = $jsFiles;
	
    my $baseDir = $inPreferences->{base};
    my $templateRef = _getFreeMarkerTemplate( $inPreferences->{templateFreeMarker} );
    
    my $processing = {
        'classes' => {
            XMLs => undef,    # array of hashes with keys 'uri' and 'textRef'
        },
        'index' => {
            XMLs => undef,    # array of hashes with keys 'uri' and 'textRef'
        },
        'all-packages'  => { XMLs => undef, },
        'methods'       => { XMLs => undef, },
        'toc'           => { XMLs => undef, },
        'constants'     => { XMLs => undef, },
        'properties'    => { XMLs => undef, },
        'deprecated'    => { XMLs => undef, },
    };

    # parse data to xml
    my $indexHtml = undef;
    my @htmlDocFileNames;
    my @htmlSupportingFileNames;

    my $xmlWriter = new XML::Writer(
        ENCODING    => 'utf-8',
        DATA_MODE   => 1,
        DATA_INDENT => 4,
        UNSAFE      => 1,
    );

    # classes
    foreach my $fileData ( @{$inCollectiveFileData} ) {

        # get (potentially multiple) xml texts from each FileData
        my $xmlData =
          VisDoc::OutputFormatter::formatFileData( $fileData, $inPreferences,
            $xmlWriter );
        my $key = 'classes';

        # store
        map { push( @{ $processing->{$key}->{XMLs} }, $_ ) } @{$xmlData};
        map { push( @htmlDocFileNames, $_->{uri} ) } @{$xmlData};
    }

    my $tocXML = '';
	my $tocHtmlRef;
	
    if ( $inPreferences->{generateNavigation} ) {

        my $tocNavigationKeys = {
            'index'         => undef,
            'all-packages'  => undef,
            'classes'       => undef,
            'methods'       => undef,
            'constants'     => undef,
            'properties'    => undef,
            'deprecated'    => undef,
        };
        my $addToTocNavigation = sub {
            my ($inKey) = @_;
            $tocNavigationKeys->{$inKey} = 1;
        };

        {
            # index.html
            my $xmlData = _createIndexHtmlPageXmlData(
                $dirInfo->{dir}->{html}, $inPreferences,
                $inCollectiveFileData,   $xmlWriter
            );
            my $key = 'index';
            if ($xmlData) {
                push( @{ $processing->{$key}->{XMLs} }, $xmlData );
                push( @htmlSupportingFileNames,         $xmlData->{uri} );
                $indexHtml = $xmlData->{uri};
            }

            &$addToTocNavigation($key);
        }

        my $processOverviewPage = sub {
            my ( $inFormatterName, $inKey ) = @_;

            my $formatter =
              $inFormatterName->new( $inPreferences, $inCollectiveFileData );
            my $xmlData = $formatter->format($xmlWriter);
            push( @{ $processing->{$inKey}->{XMLs} }, $xmlData ) if $xmlData;
            push( @htmlSupportingFileNames, $xmlData->{uri} ) if $xmlData;
            &$addToTocNavigation($inKey) if $xmlData->{hasFormattedData};
        };

        # process overview pages
        &$processOverviewPage( 'VisDoc::XMLOutputFormatterAllPackages',
            'all-packages' );
        &$processOverviewPage( 'VisDoc::XMLOutputFormatterAllClasses',
            'classes' );
        &$processOverviewPage( 'VisDoc::XMLOutputFormatterAllMethods',
            'methods' );
        &$processOverviewPage( 'VisDoc::XMLOutputFormatterAllConstants',
            'constants' );
        &$processOverviewPage( 'VisDoc::XMLOutputFormatterAllProperties',
            'properties' );
        &$processOverviewPage( 'VisDoc::XMLOutputFormatterAllDeprecated',
            'deprecated' );

        my $packagesCount = 0;
        foreach my $fileData ( @{$inCollectiveFileData} ) {
            foreach my $package ( @{ $fileData->{packages} } ) {
                $packagesCount++ if $package->{name};
                last if $packagesCount > 0;
            }
        }

        # toc
        my $formatter =
          VisDoc::XMLOutputFormatterToc->new( $inPreferences, undef,
            $inCollectiveFileData, $tocNavigationKeys );
        my $xmlData = $formatter->format($xmlWriter);
        $tocXML = $xmlData;
        my $key = 'toc';
        push( @{ $processing->{$key}->{XMLs} }, $xmlData )        if $xmlData;
        push( @htmlSupportingFileNames,         $xmlData->{uri} ) if $xmlData;

        # store TOC html to pass this to to-be-generated html files
        if ($tocXML) {
        	$tocHtmlRef = _transformXmlToHtml( $inPreferences, $tocXML->{textRef}, $templateRef, $inPreferences->{docencoding} );
        }
    }

    # add enclosing tag and XML declaration

    while ( my ( $key, $value ) = each %{$processing} ) {

        foreach my $xml ( @{ $value->{XMLs} } ) {

            my $xmlText = '<?xml version="1.0" encoding="utf-8"?>
<document>';
            $xmlText .= ${ $xml->{textRef} };
            $xmlText .= '</document>';

            $xml->{textRef} = \$xmlText;
        }
    }

    # write everything to files
    while ( my ( $key, $value ) = each %{$processing} ) {

        next if $key =~ m/^(toc)$/;    # exclude from writing to files

        foreach my $xml ( @{ $value->{XMLs} } ) {

            # write XML
            _writeXmlFile( $dirInfo->{dir}->{xml},
                "$xml->{uri}.xml", $xml->{textRef} )
              if $inPreferences->{saveXML};

            # write HTML
            my $htmlRef = _transformXmlToHtml( $inPreferences, $xml->{textRef}, $templateRef, $inPreferences->{docencoding}, {tocHtml => $$tocHtmlRef } );
           _writeHtmlFile( $dirInfo->{dir}->{html},
               "$xml->{uri}.html", $htmlRef );
        }
    }
    
    return ( $dirInfo->{dir}->{html},
        $indexHtml, \@htmlDocFileNames, \@htmlSupportingFileNames );
}

=pod

StaticMethod _createWriteDirectories ($directory, \%preferences) -> \%info

=cut

sub _createWriteDirectories {
    my ( $inDocDirectory, $inPreferences ) = @_;

    my $info       = {};
    my $isValidDir = 0;
    my $dir        = '';

    my $base = $inPreferences->{base};
    $info->{base} = $base;

    if ( $inPreferences->{saveXML} ) {
        $dir = _createSubDirectory( $inDocDirectory, $base, $VisDoc::Defaults::DESTINATION_XML );
        $isValidDir = defined stat($dir) ? 1 : 0;
        $info->{dir}->{xml}     = $dir;
        $info->{xml}->{isValid} = $isValidDir;
    }

    $dir = _createSubDirectory( $inDocDirectory, $base, $VisDoc::Defaults::DESTINATION_HTML );
    $info->{dir}->{html} = $dir;

    $dir = _createSubDirectory( $inDocDirectory, $base, $VisDoc::Defaults::DESTINATION_CSS );
    $info->{dir}->{css} = $dir;

    $dir = _createSubDirectory( $inDocDirectory, $base, $VisDoc::Defaults::DESTINATION_JS );
    $info->{dir}->{js} = $dir;

=pod
	$dir = '';
    $dir = _createSubDirectory( $inDocDirectory, $base, $VisDoc::Defaults::DESTINATION_IMG );
    $info->{img} = $dir;
=cut

    return $info;
}

=pod

StaticMethod _createSubDirectory( $docDirectory, $baseDirectory, $subDirectory ) -> $createdPath

Util method to create a sub directory below the doc directory.

=cut

sub _createSubDirectory {
    my ( $inDocDirectory, $inBaseDirectory, $inSubDirectory ) = @_;

    my $docDirectoryPath =
      File::Spec->rel2abs( $inDocDirectory, $inBaseDirectory );
    my $path = File::Spec->catdir( $docDirectoryPath, $inSubDirectory );

    my $result;
    eval { $result = File::Path::mkpath($path) };
    if ($@) {
        print "Could not create dir: $@\n";
    }
    return $path;
}

=pod

StaticMethod _writeXmlFile ( $xmlDirectory, $fileName, \$xmlText )

Writes XML text to file $fileName.

=cut

sub _writeXmlFile {
    my ( $inXmlDirectory, $inFileName, $inXmlTextRef ) = @_;

    # append the filename to the path
    my $writePath = File::Spec->catpath( '', $inXmlDirectory, $inFileName );
    File::Slurp::write_file( $writePath, { atomic => 1 }, $$inXmlTextRef );
}

=pod

StaticMethod _writeHtmlFile ( $htmlDirectory, $fileName, \$htmlText )

Writes HTML text to file $fileName.

=cut

sub _writeHtmlFile {
    my ( $inHtmlDirectory, $inFileName, $inHtmlText ) = @_;

    # append the filename to the path
    my $writePath = File::Spec->catpath( '', $inHtmlDirectory, $inFileName );
    File::Slurp::write_file( $writePath, { atomic => 1 }, $inHtmlText );
}

=pod

StaticMethod _copyCss ( $destinationDir, \%preferences )

Copies css files from the template directory to $destinationDir.

=cut

sub _copyCss {
    my ( $inDestinationDir, $inPreferences ) = @_;

    my $dir = File::Spec->abs2rel( $inPreferences->{templateCssDirectory} ) ;
    if (-d $dir) {
    	$dir = File::Spec->rel2abs($inPreferences->{templateCssDirectory}, $inPreferences->{base});
    }

    # get all .css files from that directory
    my @files;
    File::Find::find(
        {
            wanted => sub {

                # check if file is css file
                push @files, $File::Find::name
                  if ( $File::Find::name =~ /(\.css)$/ );
            },
        },
        $dir
    );

	my @outFiles;
    foreach my $file (@files) {
        my $path = File::Spec->rel2abs( $file, $inPreferences->{base} );
        my $result = File::Copy::copy( $path, $inDestinationDir );
        if ( !$result ) {
            print("Could not copy $path to $inDestinationDir: $!\n");
        } else {
        	my $localPath = '../' . $VisDoc::Defaults::DESTINATION_CSS . '/' . VisDoc::StringUtils::getLastPathComponent( $file );
        	push @outFiles, $localPath;
        }
    }
    
    return \@outFiles;
}

=pod

StaticMethod _copyJs ( $destinationDir, \%preferences ) -> \@files

Copies javascript files from the template directory to $destinationDir.

=cut

sub _copyJs {
    my ( $inDestinationDir, $inPreferences ) = @_;

    my $dir = File::Spec->abs2rel( $inPreferences->{templateJsDirectory} ) ;
    if (-d $dir) {
    	$dir = File::Spec->rel2abs($inPreferences->{templateJsDirectory}, $inPreferences->{base});
    }

    # get all .js files from that directory
    my @files;
    File::Find::find(
        {
            wanted => sub {

                # check if file is javascript file
                push @files, $File::Find::name
                  if ( $File::Find::name =~ /(\.js)$/ );
            },
        },
        $dir
    );

	my @outFiles;
    foreach my $file (@files) {
        my $path = File::Spec->rel2abs( $file, $inPreferences->{base} );
        my $result = File::Copy::copy( $path, $inDestinationDir );
        if ( !$result ) {
            print("Could not copy $path to $inDestinationDir: $!\n");
        } else {
        	my $localPath = '../' . $VisDoc::Defaults::DESTINATION_JS . '/' . VisDoc::StringUtils::getLastPathComponent( $file );
        	push @outFiles, $localPath;
        }
    }
    
    return \@outFiles;
}

=pod

StaticMethod _getFreeMarkerTemplate( $templatePath ) -> $textRef

Reads FreeMarker text from file.

=cut

sub _getFreeMarkerTemplate {
    my ( $inTemplatePath ) = @_;

    my $path = File::Spec->rel2abs( $inTemplatePath );

    die "No such file $path" unless -e $path;

    my $templateText = readFile($path);

    die("Could not load FreeMarker file: $path\n") if !$templateText;

    return \$templateText;
}

=pod

StaticMethod _transformXmlToHtml( \$preferences, \$xmlText, \$template, \$data ) -> \$html

Transforms XML to HTML using a FreeMarker template.
Uses LibXML engine (must be installed).

=cut

sub _transformXmlToHtml {
    my ( $inPreferences, $inXmlTextRef, $inTemplateRef, $inEncoding, $inData ) = @_;

	my $tpp = XML::TreePP->new();
	$tpp->set( force_array => [ 'item', 'field', 'fields', 'memberSummaryPart', 'fromClass', 'memberSection', 'member', 'listGroup' ] );
	$tpp->set( attr_prefix => '' );
	
	my $data = $tpp->parse( ${$inXmlTextRef} );
	# remove extra level 'document'
	if ($data->{document}) {
		$data = $data->{document};
		# let the parser know the type of document
		$data->{document} = 1;
	}
	$data->{encoding} = $inEncoding;
	$data->{showNavigation} = $inPreferences->{generateNavigation};
	
	# merge data
	if ($inData) {
		foreach my $key ( keys %{$inData} ) {
			$data->{$key} = $inData->{$key};
		}
	}

   	#use Data::Dumper;
    #print STDOUT "data=" . Dumper($data);
    
    my $freeMarkerTemplate = ${$inTemplateRef};
    
    my $parser = new Foswiki::Plugins::FreeMarkerPlugin::FreeMarkerParser();
    my $debug = 0;
	$parser->setDebugLevel( $debug ? 0x1F : 0 );

    my $parsed = $parser->parse($freeMarkerTemplate, $data);
    #print STDOUT "parsed=" . $parsed . "\n";

    return \$parsed;
}

=pod

StaticMethod _createIndexHtmlPageXmlData( $htmlDirectory, \%preferences, \@collectiveFileData, $xmlWriter ) -> { uri => ..., textRef => ... }

Creates index.html if it does not exist yet.

=cut

sub _createIndexHtmlPageXmlData {
    my ( $inHtmlDirectory, $inPreferences, $inCollectiveFileData, $inXmlWriter )
      = @_;

    my $file = "$inHtmlDirectory/index.html";
    my $path = File::Spec->rel2abs( $file, $inPreferences->{base} );

    use File::stat;
    my $st = stat($path);
    my $exists = $st ? 1 : 0;

    # does not exist yet
    my $formatter = VisDoc::XMLOutputFormatterIndexPage->new( $inPreferences,
        $inCollectiveFileData, $exists );

    return $formatter->format($inXmlWriter);
}

sub _cleanupSpacesBetweenSpans {
    my ($htmlRef) = @_;

    ${$htmlRef} =~ s/(<\/span>)[[:space:]]+(<span)/$1$2/go;
}

1;

# VisDoc - Code documentation generator, http://visdoc.org
# This software is licensed under the MIT License
#
# The MIT License
#
# Copyright (c) 2010 Arthur Clemens, VisDoc contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
