# See bottom of file for license and copyright information

=pod

Base class for XML output formatters. Includes common methods that are used by subclasses.

Subclasses:
- XMLOutputFormatterClassPage
- XMLOutputFormatterPackagePage (not yet created)

=cut

package VisDoc::XMLOutputFormatterBase;

use strict;
use warnings;
use XML::Writer();
use VisDoc::Formatter;
use VisDoc::Defaults;
use VisDoc::StringUtils;

=pod

=cut

sub new {
    my ( $class, $inPreferences, $inLanguage, $inData ) = @_;
    my $this = {};
    $this->{preferences} = $inPreferences;
    $this->{language}    = $inLanguage;
    $this->{data}        = $inData;
    bless $this, $class;
    return $this;
}

=pod

format ($classData) -> {uri => $uri, textRef => \$xmlText, hasFormattedData => $bool }

=cut

sub format {
    my ( $this, $inXmlWriter ) = @_;

    my $xmlText = '';
    $inXmlWriter->setOutput( \$xmlText );

    my $hasFormattedData = $this->_formatData($inXmlWriter);

    return {
        uri              => $this->_uri(),
        textRef          => \$xmlText,
        hasFormattedData => $hasFormattedData
    };
}

=pod

_writeLinkXml( $writer, $label, $uri, $options)

options:
memberName
packagePath

Writes link XML.

=cut

sub _writeLinkXml {
    my ( $this, $inWriter, $inLabel, $inUri, $inOptions ) = @_;

    $inWriter->startTag('link');
    $inWriter->cdataElement( 'name',   $inLabel );
    $inWriter->cdataElement( 'uri',    $inUri ) if $inUri;
    $inWriter->cdataElement( 'memberName', $inOptions->{memberName} ) if $inOptions->{memberName};
    $inWriter->cdataElement( 'packagePath', $inOptions->{packagePath} )  if $inOptions->{packagePath};
    
    $inWriter->endTag('link');
}

=pod

_writeValueXml( $writer, $value )

Writes value as:

<item>
	<value>
		<![CDATA[ the value ]]>
	</value>
</item>
				
=cut

sub _writeValueXml {
    my ( $this, $inWriter, $inValue ) = @_;

    $inWriter->startTag('item');
    $inWriter->cdataElement( 'value', $inValue );
    $inWriter->endTag('item');
}

=pod

Writes the XML declaration. Override to change behaviour.

=cut

sub _writeXmlDeclaration {
    my ( $this, $inWriter ) = @_;

    $inWriter->xmlDecl("utf-8");
}

=pod

_docTerm( $key) -> $text

Gets the doc term from Language.pm.

=cut

sub _docTerm {
    my ( $this, $inKey ) = @_;

    return VisDoc::Language::getDocTerm( $inKey, $this->{language} );
}

=pod

=cut

sub _uri {
    my ($this) = @_;

    return $this->{data}->getUri();
}

=pod

=cut

sub _title {
    my ($this) = @_;

    return $this->{data}->{name};
}

=pod

=cut

sub _htmlTitle {
    my ($this) = @_;

	return $this->_title() . ' | ' . $this->{preferences}->{projectTitle};
}

=pod

_formatData ($classData) -> $bool

Writes out formatted xml.

To be implemented by subclasses.

Returns true if data is formatted, otherwise false

=cut

sub _formatData {
    my ( $this, $inWriter ) = @_;

    return 0;
}

=pod

=cut

sub _writeAssetLocations {
    my ( $this, $inWriter ) = @_;

	$this->_writeCSSLocation($inWriter);
	$this->_writeJsLocation($inWriter);
}

=pod

=cut

sub _writeCSSLocation {
    my ( $this, $inWriter ) = @_;
    
    foreach my $file (@{$this->{preferences}->{cssFiles}}) {
		$inWriter->cdataElement('cssFile', $file);
	}
}

=pod

=cut

sub _writeJsLocation {
    my ( $this, $inWriter ) = @_;

	foreach my $file (@{$this->{preferences}->{jsFiles}}) {
		$inWriter->cdataElement('jsFile', $file);
	}
}

=pod

=cut

sub _writeTitleAndPageId {
    my ( $this, $inWriter ) = @_;

    $inWriter->cdataElement( 'pageClass', $this->_uri() );
    $inWriter->cdataElement( 'htmlTitle',     $this->_htmlTitle());
    $inWriter->cdataElement( 'title',     $this->_title());
}

=pod

To be implemented by subclasses.

=cut

sub _writeClassData {
    my ( $this, $inWriter ) = @_;

    # ...
}

=pod

_writeDetailsValue( $writer, $value, $key, $docTermKey)

=cut

sub _writeDetailsValue {
    my ( $this, $inWriter, $inValue, $inKey, $inDocTermKey ) = @_;

    my $value = '';
    if ($inValue) {
        $value = $inValue;
    }
    else {
        my $values = $this->_getFieldValues($inKey);
        $value = join( ", ", @{$values} ) if $values;
    }
    return if !$value;

    $inWriter->startTag('item');

    $inWriter->cdataElement( 'title', $this->_docTerm($inDocTermKey) );
    $inWriter->cdataElement( 'value', $value );

    $inWriter->endTag('item');
}

=pod

_getFieldValues( $key ) -> \@values

=cut

sub _getFieldValues {
    my ( $this, $inKey ) = @_;

    return undef if !$inKey;
    return undef if !$this->{data}->{javadoc};
    my $fields = $this->{data}->{javadoc}->getMultipleFieldsWithName($inKey);
    return undef if !$fields;

    my $values = ();
    map { push( @{$values}, $_->{value} ) if ( $_->{value} ) } @{$fields};

    return $values;
}

=pod

_writeAttribute( $xmlWriter, \%attributes )

=\%attributes= = {
	isInterface => $bool,
	isClass => $bool,	
	isMethod => $bool,
	isPublic => $bool,
	type => $scalar,
	language => $string,
	access => \@access,
	summary => $string,
	className => $string,
};

=cut

sub _writeAttribute {
    my ( $this, $inWriter, $inAttributes ) = @_;

    #use Data::Dumper;
    #print("_writeAttribute:" . Dumper($inAttributes));

    $inWriter->cdataElement( 'interface', 'true' )
      if $inAttributes->{isInterface};
    $inWriter->cdataElement( 'class', 'true' ) if $inAttributes->{isClass};

    if ( !$inAttributes->{isPublic} ) {
        $inWriter->cdataElement( 'private', 'true' );
    }

=pod
	#if ($inAttributes->{type}) {
	
		my $language = $inAttributes->{language} || $this->{language};
		
		my $formatter   = VisDoc::Formatter::formatter( $language );
		
		my $access = $inAttributes->{access};
		my $accessStr = '';
		if ($inAttributes->{isClass} || $inAttributes->{isInterface}) {

			$accessStr = $formatter->formatClassAccess( $inAttributes->{type}, $access );
			
		} elsif ($inAttributes->{isMethod}) {

			$accessStr = $formatter->formatMethodAccess( $inAttributes->{type}, $access );
		} elsif ($inAttributes->{isProperty}) {

			$accessStr = $formatter->formatPropertyAccess( $inAttributes->{type}, $access );
		}

		$inWriter->cdataElement('attribute', $accessStr);
	#}
=cut

    $inWriter->cdataElement( 'summary', $inAttributes->{summary} )
      if $inAttributes->{summary};

    $inWriter->cdataElement( 'className', $inAttributes->{className} )
      if $inAttributes->{className};
}

=pod

=cut

sub _writeFooter {
    my ( $this, $inWriter ) = @_;

    $inWriter->startTag('meta');

    # copyright
    my $footerText = $this->{preferences}->{footerText};
    $inWriter->cdataElement( 'footerText', $footerText ) if $footerText;

    # show/hide TOC (if frameset)
    if ( $this->{preferences}->{generateNavigation} ) {
        $inWriter->cdataElement( 'showTOC', $this->_docTerm('menu_showTOC') );
        $inWriter->cdataElement( 'hideTOC', $this->_docTerm('menu_hideTOC') );
    }

    # show/hide private members
    if ( $this->{preferences}->{listPrivate} ) {
        $inWriter->cdataElement( 'showPrivate',
            $this->_docTerm('menu_showPrivate') );
        $inWriter->cdataElement( 'hidePrivate',
            $this->_docTerm('menu_hidePrivate') );
    }

    $inWriter->endTag('meta');
}

=pod

_writeClassItem( $xmlWriter, $name, $uri, \%attributes ) 

=\%attributes= = {

	path => $string,
	memberName => $string,
	isInterface => $bool,
	isClass => $bool,
	isPrivate => $bool,
	
};

<item>
	<link>
		<name>
			<![CDATA[ReferencedClass]]>
		</name>
		<uri>
			<![CDATA[path_to_ReferencedClass]]>
		</uri>
		<packagePath>
			<![CDATA[path.to.]]>
		</packagePath>
	</link>
	<class>
		<![CDATA[true]]>
	</class>	
</item>

=cut

sub _writeClassItem {
    my ( $this, $inWriter, $inName, $inUri, $inAttributes ) = @_;

    $inWriter->startTag('item');

    my $packagePath = $inAttributes->{path} if $inAttributes->{path};
    
    my $memberName = $inAttributes->{memberName}
      if $inAttributes && $inAttributes->{memberName};

    $this->_writeLinkXml( $inWriter, $inName, $inUri, {memberName => $memberName, packagePath => $packagePath} );
    $this->_writeAttribute( $inWriter, $inAttributes );

    $inWriter->endTag('item');
}

=pod

getSummaryLine( $javadocData, $fileData ) -> $text

=cut

sub getSummaryLine {
    my ( $this, $inJavadocData, $inFileData ) = @_;

    return '' if !$inJavadocData;

    my $summary     = '';
    my $description = $inJavadocData->getDescription();
    if ($description) {
        $description = $inFileData->getContents($description);
        my ( $beforeFirstLineTag, $summaryLine, $rest ) =
          $inFileData->getDescriptionParts($description);

        if ( $summaryLine && !$beforeFirstLineTag ) {
            $summary = $summaryLine;
        }
        else {
            $summary = "$beforeFirstLineTag$summaryLine$rest";
        }
    }
    return $summary;
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
