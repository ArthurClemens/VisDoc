# See bottom of file for license and copyright information

package VisDoc::XMLOutputFormatterAllClasses;
use base 'VisDoc::XMLOutputFormatterListingBase';

use strict;
use warnings;
use XML::Writer();

our $URI = 'all-classes';

=pod

=cut

sub _uri {
    my ($this) = @_;

    return $URI;
}

sub _title {
    my ($this) = @_;

    return $this->_docTerm('all_classes_title');
}

=pod

_writeList( $xmlWriter ) -> $bool

Create a list of classes.
	
=cut

sub _writeList {
    my ( $this, $inWriter ) = @_;

    my $classes;
    foreach my $fileData ( @{ $this->{data} } ) {
        foreach my $package ( sort @{ $fileData->{packages} } ) {
            next
              if !$this->{preferences}->{listPrivate} && !$package->isPublic();
            foreach my $class ( @{ $package->{classes} } ) {
                next
                  if !$this->{preferences}->{listPrivate}
                      && !$class->isPublic();
                push @$classes,
                  { class => $class, language => $fileData->{language} };
            }
        }
    }

    return 0 if ( !$classes || !scalar @{$classes} );

    # sort classes
    @{$classes} =
      sort { lc( $a->{class}->{name} ) cmp lc( $b->{class}->{name} ) }
      @{$classes};

    $inWriter->startTag('tocList');
    $inWriter->startTag('listGroup');

    foreach my $classHash ( @{$classes} ) {
        my $class = $classHash->{class};

        my $summary =
          $this->getSummaryLine( $class->{javadoc}, $class->{fileData} );

        my $attributes = {
            isPublic => $class->isPublic(),
            isClass  => ( $class->{type} & $VisDoc::ClassData::TYPE->{CLASS} ),
            isInterface =>
              ( $class->{type} & $VisDoc::ClassData::TYPE->{INTERFACE} ),
            type     => $class->{type},
            language => $classHash->{language},
            access   => $class->{access},
            summary  => $summary,
        };
        $this->_writeClassItem( $inWriter, $class->{name}, $class->getUri(),
            $attributes );
    }

    $inWriter->endTag('listGroup');
    $inWriter->endTag('tocList');
    return 1;
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
