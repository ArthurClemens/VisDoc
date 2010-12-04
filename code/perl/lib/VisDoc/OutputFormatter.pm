# See bottom of file for license and copyright information

package VisDoc::OutputFormatter;

use strict;
use warnings;
use VisDoc::FileData;
use VisDoc::Defaults;
use VisDoc::XMLOutputFormatterClassPage;
use VisDoc::XMLOutputFormatterPackagePage;
use VisDoc::Language;

my $doctermsInited = 0;

=pod

StaticMethod formatFileData ($fileData, \%preferences ) -> \@xmlData

Returns an array of xmlData hashes, each with keys:
- uri: the uri (without file extension)
- textRef: reference to the XML text

=cut

sub formatFileData {
    my ( $inFileData, $inPreferences, $inXmlWriter ) = @_;

    _initDocTerms( $inPreferences->{base} );

    my $xmlData;    # array ref

    foreach my $packageData ( @{ $inFileData->{packages} } ) {

        next if $packageData->isExcluded();
        next if !$inPreferences->{listPrivate} && !$packageData->isPublic();

        # package
        if ( $packageData->{name} ) {

            # excludes unmaterialized packages, such as with as2
            my $formatter =
              VisDoc::XMLOutputFormatterPackagePage->new( $inPreferences,
                $inFileData->{language}, $packageData );
            push @{$xmlData}, $formatter->format($inXmlWriter);
        }

        # class
        foreach my $classData ( @{ $packageData->{classes} } ) {
            next if $classData->isExcluded();
            next if !$inPreferences->{listPrivate} && !$classData->isPublic();
            my $formatter =
              VisDoc::XMLOutputFormatterClassPage->new( $inPreferences,
                $inFileData->{language}, $classData );
            push @{$xmlData}, $formatter->format($inXmlWriter);
        }

    }
    return $xmlData;
}

=pod

=cut

sub _initDocTerms {
    my ($inBase) = @_;

    return if $doctermsInited;

    {

        # docterms
        my $path =
          File::Spec->rel2abs( $VisDoc::Defaults::FILE_DOCTERMS, $inBase );
        my $text = VisDoc::readFile($path);
        VisDoc::Language::initDocTerms($text);
    }
    {

        # docterms
        my $path =
          File::Spec->rel2abs( $VisDoc::Defaults::FILE_JAVADOCTERMS, $inBase );
        my $text = VisDoc::readFile($path);
        VisDoc::Language::initJavadocTerms($text);
    }

    $doctermsInited = 1;
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
