# See bottom of file for license and copyright information

package VisDoc::XMLOutputFormatterListingBase;
use base 'VisDoc::XMLOutputFormatterBase';

use strict;
use warnings;
use XML::Writer();

=pod

=cut

sub new {
    my ( $class, $inPreferences, $inData ) = @_;

    my VisDoc::XMLOutputFormatterListingBase $this =
      $class->SUPER::new( $inPreferences, undef, $inData );

    bless $this, $class;
    return $this;
}

=pod

_formatData ($xmlWriter) -> $bool

=cut

sub _formatData {
    my ( $this, $inWriter ) = @_;

    $this->_writeAssetLocations($inWriter);
    $this->_writeTitleAndPageId($inWriter);
    my $hasFormattedData = $this->_writeList($inWriter);
    $this->_writeFooter($inWriter);
    return $hasFormattedData;
}

=pod

_writeList( $xmlWriter ) -> $bool

to be implemented by subclasses

=cut

sub _writeList {
    my ( $this, $inWriter ) = @_;

    return 0;
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
