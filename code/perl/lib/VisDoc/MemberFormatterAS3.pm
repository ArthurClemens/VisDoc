# See bottom of file for license and copyright information

package VisDoc::MemberFormatterAS3;

use base 'VisDoc::MemberFormatterAS2';
use strict;
use warnings;

sub new {
    my ( $class, $inFileParser ) = @_;

    my VisDoc::MemberFormatterAS3 $this = $class->SUPER::new();

    bless $this, $class;
    return $this;
}

=pod

=cut

sub getPropertyTypeString {
    my ( $this, $inElement, $inMember ) = @_;

    my $outText = '';
    if ( $inElement =~ m/\bPROPERTYTYPE\b/ ) {
        my $type = '';    # do not write 'var' for AS2
        if ( $inMember->{type} ) {
            $type = 'const'
              if ( $inMember->{type} & $VisDoc::MemberData::TYPE->{CONST} );
            $type = 'namespace'
              if ( $inMember->{type} & $VisDoc::MemberData::TYPE->{NAMESPACE} );
        }
        $inElement =~ s/\bPROPERTYTYPE\b/$type/;
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
