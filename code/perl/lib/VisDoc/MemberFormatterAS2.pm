# See bottom of file for license and copyright information

package VisDoc::MemberFormatterAS2;

use base 'VisDoc::MemberFormatterBase';
use strict;
use warnings;

sub new {
    my ( $class, $inFileParser ) = @_;

    my VisDoc::MemberFormatterAS2 $this = $class->SUPER::new();

    $this->{PATTERN_PARAMETER_STRING} = 'VARARGS|NAME|:DATATYPE| = VALUE';
    $this->{PATTERN_MEMBER_TYPE_INFO_PROPERTY} = ' : DATATYPE';
    $this->{PATTERN_MEMBER_TYPE_INFO_METHOD}   = '(PARAMETERS)| : RETURNTYPE';
    $this->{PATTERN_MEMBER_PROPERTY_LEFT} =
      'ACCESS |PROPERTYTYPE |NAME|:DATATYPE| = VALUE';
    $this->{PATTERN_MEMBER_METHOD_LEFT}  = 'ACCESS |METHODTYPE |NAME ';
    $this->{PATTERN_MEMBER_METHOD_RIGHT} = '(PARAMETERS)| : RETURNTYPE';

    bless $this, $class;
    return $this;
}

=pod

=cut

sub getAccessString {
    my ( $this, $inElement, $inMember ) = @_;

    my @access = @{ $inMember->{access} };
    @access = grep { $_ ne 'public' } @access;    # do not show 'public'
    my $value = join( " ", @access );
    return $this->getDataString( $inElement, $value, 'ACCESS', undef );
}

=pod

=cut

sub getPropertyTypeString {
    my ( $this, $inElement, $inMember ) = @_;

    my $outText = '';
    if ( $inElement =~ m/\bPROPERTYTYPE\b/ ) {
        my $type = '';    # do not write 'var' for AS2
        $inElement =~ s/\bPROPERTYTYPE\b/$type/;
        $outText .= $inElement;
    }
    return $outText;
}

=pod

=cut

sub getMethodTypeString {
    my ( $this, $inElement, $inMember ) = @_;

    my $outText = '';
    if ( $inElement =~ m/\bMETHODTYPE\b/ ) {
        my $type = 'function';
        $inElement =~ s/\bMETHODTYPE\b/$type/;
        $outText .= $inElement;
    }
    return $outText;
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
