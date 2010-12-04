# See bottom of file for license and copyright information

package VisDoc::XMLOutputFormatterAllMethods;
use base 'VisDoc::XMLOutputFormatterListingBase';

use strict;
use warnings;
use warnings;
use XML::Writer();

our $URI = 'all-methods';

=pod

=cut

sub _uri {
    my ($this) = @_;

    return $URI;
}

sub _title {
    my ($this) = @_;

    return $this->_docTerm('all_methods_title');
}

=pod

_writeList( $xmlWriter ) -> $bool

Create a list of classes.
	
=cut

sub _writeList {
    my ( $this, $inWriter ) = @_;

    my $methods;
    foreach my $fileData ( @{ $this->{data} } ) {

        foreach my $package ( @{ $fileData->{packages} } ) {
            next
              if !$this->{preferences}->{listPrivate} && !$package->isPublic();
            foreach my $function ( @{ $package->{functions} } ) {
                next
                  if !$this->{preferences}->{listPrivate}
                      && !$function->isPublic();
                my $methodId = $function->getId() . ".$package->{name}";
                push @$methods,
                  {
                    id       => $methodId,
                    method   => $function,
                    language => $fileData->{language},
                    fileData => $fileData,
                    package  => $package
                  };
            }
            foreach my $class ( @{ $package->{classes} } ) {
                next
                  if !$this->{preferences}->{listPrivate}
                      && !$class->isPublic();
                foreach my $method ( @{ $class->{methods} } ) {
                    next
                      if !$this->{preferences}->{listPrivate}
                          && !$method->isPublic();
                    my $methodId =
                      $method->getId() . ".$class->{name}.$package->{name}";
                    push @$methods,
                      {
                        id       => $methodId,
                        method   => $method,
                        language => $fileData->{language},
                        fileData => $fileData,
                        class    => $class
                      };
                }
            }
        }
    }

    return 0 if ( !$methods || !scalar @{$methods} );

    # sort methods
    @{$methods} =
      sort { lc( $a->{id} ) cmp lc( $b->{id} ) } @{$methods};

    # find duplicate member names and add class names
    my $refCounts;
    foreach my $methodHash ( @{$methods} ) {
        my $name = $methodHash->{method}->{name};
        $refCounts->{$name}->{count}++;
        push @{ $refCounts->{$name}->{methods} }, $methodHash;
    }
    while ( my ( $key, $value ) = each(%$refCounts) ) {
        next if $refCounts->{$key}->{count} < 2;
        foreach my $methodHash ( @{ $refCounts->{$key}->{methods} } ) {
            $methodHash->{isDuplicateName} = 1;
        }
    }

    $inWriter->startTag('tocList');
    $inWriter->startTag('listGroup');

    foreach my $methodHash ( @{$methods} ) {
        my $method = $methodHash->{method};

        my $summary =
          $this->getSummaryLine( $method->{javadoc}, $methodHash->{fileData} );

        my $className;
        $className = $methodHash->{class}->{name}
          if $methodHash->{isDuplicateName};

        my $attributes = {
            isMethod   => 1,
            memberName => $method->{nameId},
            isPublic   => $method->isPublic(),
            language   => $methodHash->{language},
            access     => $method->{access},
            type       => $method->{type},
            summary    => $summary,
            className  => $className,
        };
        my $uri = '';
        if ( $methodHash->{package} ) {
            $uri = $methodHash->{package}->getUri();
        }
        elsif ( $methodHash->{class} ) {
            $uri = $methodHash->{class}->getUri();
        }
        $this->_writeClassItem( $inWriter, $method->{name}, $uri, $attributes );
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
