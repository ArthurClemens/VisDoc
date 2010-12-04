# See bottom of file for license and copyright information

package VisDoc::XMLOutputFormatterToc;
use base 'VisDoc::XMLOutputFormatterAllPackages';

use strict;
use warnings;
use XML::Writer();

=pod

=cut

sub new {
    my ( $class, $inPreferences, $inLanguage, $inData, $inTocNavigationKeys ) =
      @_;

    my VisDoc::XMLOutputFormatterToc $this =
      $class->SUPER::new( $inPreferences, $inData );

    $this->{tocNavigationKeys} = $inTocNavigationKeys;
    bless $this, $class;
    return $this;
}

=pod

_formatData ($xmlWriter, $classData) -> $bool

=cut

sub _formatData {
    my ( $this, $inWriter ) = @_;

    $inWriter->startTag('navigation');
    $inWriter->startTag('tocList');
    $this->_writeDocTitle($inWriter);

    $inWriter->startTag('listGroup');
    $inWriter->cdataElement( 'id', 'treemenu' );

    my ( $packages, $languages ) = $this->_getPackages();

    my $title;
    if ( scalar @{$packages} ) {
        $title =
          VisDoc::Language::getDocTerm( 'all_packages_simple_title',
            $this->{language} );
    }
    else {
        $title =
          VisDoc::Language::getDocTerm( 'all_classes_simple_title',
            $this->{language} );
    }
    $inWriter->cdataElement( 'listGroupTitle', $title );

    $this->_writePackages( $inWriter, $packages, $languages );

    $inWriter->endTag('listGroup');
    $inWriter->endTag('tocList');

    $this->_writeTocNavigation($inWriter);

    $inWriter->endTag('navigation');

    return 1;
}

=pod

<docTitle>
	<link>
		<name><![CDATA[Documentation]]></name>
		<uri><![CDATA[index]]></uri>
	</link>
</docTitle>
	
=cut

sub _writeDocTitle {
    my ( $this, $inWriter ) = @_;

    $inWriter->startTag('listGroup');
    $inWriter->startTag('item');
    $inWriter->startTag('link');

    $inWriter->cdataElement( 'name',
        $this->{preferences}->{projectTitle});
    $inWriter->cdataElement( 'uri', 'index' );
    $inWriter->endTag('link');
    $inWriter->endTag('item');
    $inWriter->endTag('listGroup');
}

=pod

<item>
	<link>
		<name>
			<![CDATA[Main]]>
		</name>
		<uri>
			<![CDATA[index]]>
		</uri>
	</link>
</item>

=cut

sub _writeTocNavigation {
    my ( $this, $inWriter ) = @_;

    return if !$this->{tocNavigationKeys};

    $inWriter->startTag('globalNav');

    my $callToWriteLink = sub {
        my ( $inTitleKey, $inUri ) = @_;

        $inWriter->startTag('item');
        $this->_writeLinkXml( $inWriter, $this->_docTerm($inTitleKey), $inUri );
        $inWriter->endTag('item');
    };

    my $callToWriteName = sub {
        my ($inTitleKey) = @_;

        $inWriter->startTag('item');
        $inWriter->cdataElement( 'name', $this->_docTerm($inTitleKey) );
        $inWriter->endTag('item');
    };

    my $keys = $this->{tocNavigationKeys};

    if ( $keys->{'all-packages'} ) {
        &$callToWriteLink( 'tree_link',
            $VisDoc::XMLOutputFormatterAllPackages::URI );
    }
    else {
        &$callToWriteName('tree_link');
    }

    if ( $keys->{'classes'} ) {
        &$callToWriteLink( 'all_classes_link',
            $VisDoc::XMLOutputFormatterAllClasses::URI );
    }
    else {
        &$callToWriteName('all_classes_link');
    }

    if ( $keys->{'methods'} ) {
        &$callToWriteLink( 'all_methods_link',
            $VisDoc::XMLOutputFormatterAllMethods::URI );
    }
    else {
        &$callToWriteName('all_methods_link');
    }

    if ( $keys->{'constants'} ) {
        &$callToWriteLink( 'all_constants_link',
            $VisDoc::XMLOutputFormatterAllConstants::URI );
    }
    else {
        &$callToWriteName('all_constants_link');
    }

    if ( $keys->{'properties'} ) {
        &$callToWriteLink( 'all_properties_link',
            $VisDoc::XMLOutputFormatterAllProperties::URI );
    }
    else {
        &$callToWriteName('all_properties_link');
    }

    if ( $keys->{'deprecated'} ) {
        &$callToWriteLink( 'all_deprecated_link',
            $VisDoc::XMLOutputFormatterAllDeprecated::URI );
    }
    else {
        &$callToWriteName('all_deprecated_link');
    }

    $inWriter->endTag('globalNav');
}

=pod

=cut

sub _uri {
    my ($this) = @_;

    return 'toc';
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
