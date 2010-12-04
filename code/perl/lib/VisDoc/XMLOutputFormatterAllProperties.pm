# See bottom of file for license and copyright information

package VisDoc::XMLOutputFormatterAllProperties;
use base 'VisDoc::XMLOutputFormatterListingBase';

use strict;
use warnings;
use XML::Writer();

our $URI = 'all-properties';

=pod

=cut

sub _uri {
    my ($this) = @_;

    return $URI;
}

sub _title {
    my ($this) = @_;

    return $this->_docTerm('all_properties_title');
}

sub _ignore {
    my ( $this, $inAttribute ) = @_;

    return 0;
}

=pod

_writeList( $xmlWriter ) -> $bool

Create a list of classes.
	
=cut

sub _writeList {
    my ( $this, $inWriter ) = @_;

    my $properties;
    foreach my $fileData ( @{ $this->{data} } ) {
        foreach my $package ( @{ $fileData->{packages} } ) {
            next
              if !$this->{preferences}->{listPrivate} && !$package->isPublic();
            foreach my $class ( @{ $package->{classes} } ) {
                next
                  if !$this->{preferences}->{listPrivate}
                      && !$class->isPublic();
                foreach my $property ( @{ $class->{properties} } ) {
                    next if $this->_ignore( $property->{type} );
                    next
                      if !$this->{preferences}->{listPrivate}
                          && !$property->isPublic();

                    my $id =
                      $property->getId() . ".$class->{name}.$package->{name}";
                    push @$properties,
                      {
                        id       => $id,
                        property => $property,
                        language => $fileData->{language},
                        fileData => $fileData,
                        class    => $class
                      };
                }
            }
        }
    }

    return 0 if ( !$properties || !scalar @{$properties} );

    # sort classes
    @{$properties} =
      sort { lc( $a->{id} ) cmp lc( $b->{id} ) } @{$properties};

    # find duplicate member names and add class names
    my $refCounts;
    foreach my $propertyHash ( @{$properties} ) {
        my $name = $propertyHash->{property}->{name};
        $refCounts->{$name}->{count}++;
        push @{ $refCounts->{$name}->{properties} }, $propertyHash;
    }
    while ( my ( $key, $value ) = each(%$refCounts) ) {
        next if $refCounts->{$key}->{count} < 2;
        foreach my $propertyHash ( @{ $refCounts->{$key}->{properties} } ) {
            $propertyHash->{isDuplicateName} = 1;
        }
    }

    $inWriter->startTag('tocList');
    $inWriter->startTag('listGroup');

    foreach my $propertyHash ( @{$properties} ) {
        my $property = $propertyHash->{property};

        my $summary =
          $this->getSummaryLine( $property->{javadoc},
            $propertyHash->{fileData} );

        my $className;
        $className = $propertyHash->{class}->{name}
          if $propertyHash->{isDuplicateName};

        my $attributes = {
            isProperty => 1,
            memberName => $property->{name},
            isPublic   => $property->isPublic(),
            language   => $propertyHash->{language},
            access     => $property->{access},
            type       => $property->{type},
            summary    => $summary,
            className  => $className,
        };
        my $uri = '';
        if ( $propertyHash->{class} ) {
            $uri = $propertyHash->{class}->getUri();
        }
        elsif ( $propertyHash->{package} ) {
            $uri = $propertyHash->{package}->getUri();
        }
        $this->_writeClassItem( $inWriter, $property->{name}, $uri,
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
