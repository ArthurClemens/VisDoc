# See bottom of file for license and copyright information

package VisDoc::XMLOutputFormatterAllPackages;
use base 'VisDoc::XMLOutputFormatterListingBase';

use strict;
use warnings;
use XML::Writer();

our $URI = 'all-packages';

=pod

=cut

sub _uri {
    my ($this) = @_;

    return $URI;
}

sub _title {
    my ($this) = @_;

    return $this->_docTerm('tree_title');
}

=pod

_writeList( $xmlWriter ) -> $bool

Create a list of:

package A
	class
	class
package B
	class
	class
	
=cut

sub _writeList {
    my ( $this, $inWriter ) = @_;

    my ( $packages, $languages ) = $this->_getPackages();
    return 0 if !scalar @{$packages};

    $inWriter->startTag('tocList');
    $this->_writePackages( $inWriter, $packages, $languages );
    $inWriter->endTag('tocList');

    return 1;
}

=pod

=cut

sub _getPackages {
    my ($this) = @_;

    my $packages;
    my $languages
      ; # store the language of each class to pass with the class attributes later on
    foreach my $fileData ( @{ $this->{data} } ) {
        foreach my $package ( sort @{ $fileData->{packages} } ) {
            next
              if !$this->{preferences}->{listPrivate} && !$package->isPublic();
            push @{$packages}, $package;
            $languages->{ $package->{name} } = $fileData->{language};
        }
    }

    return 0 if ( !$packages || !scalar @{$packages} );

    # sort packages by name
    if (scalar @{$packages} > 1) {
    	@{$packages} = sort { $a->{name} cmp $b->{name} } @{$packages};
	}
	
    return ( $packages, $languages );
}

=pod

=cut

sub _writePackages {
    my ( $this, $inWriter, $inPackages, $inLanguages ) = @_;

    foreach my $package ( @{$inPackages} ) {

        $inWriter->startTag('listGroup');

        if ( $package->{name} ) {
            $inWriter->startTag('listGroupTitle');
            $inWriter->startTag('item');
            $this->_writeLinkXml( $inWriter, $package->{name},
                $package->getUri() );
            $inWriter->cdataElement( 'package', 'true' );
            $inWriter->endTag('item');
            $inWriter->endTag('listGroupTitle');
            $inWriter->startTag('listGroup');
        }

        my $classes = $package->{classes};
		
        foreach my $class ( sort @{$classes} ) {
            next if $class->isExcluded();
            next if !$this->{preferences}->{listPrivate} && !$class->isPublic();
            my $classpath = $class->getClasspathWithoutName();
            $classpath .= '.' if $classpath;
            my $attributes = {
                path     => $classpath,
                isPublic => $class->isPublic(),
                isClass =>
                  ( $class->{type} & $VisDoc::ClassData::TYPE->{CLASS} ),
                isInterface =>
                  ( $class->{type} & $VisDoc::ClassData::TYPE->{INTERFACE} ),
                type     => $class->{type},
                language => $inLanguages->{ $package->{name} },
                access   => $class->{access},
            };
            $this->_writeClassItem( $inWriter, $class->{name}, $class->getUri(),
                $attributes );
        }

        if ( $package->{name} ) {
            $inWriter->endTag('listGroup');
        }
        $inWriter->endTag('listGroup');
    }
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
