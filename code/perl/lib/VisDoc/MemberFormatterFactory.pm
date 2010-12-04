# See bottom of file for license and copyright information

package VisDoc::MemberFormatterFactory;

use strict;
use warnings;
use VisDoc::ParserAS2;
use VisDoc::ParserAS3;
use VisDoc::ParserJava;

=pod

getMemberFormatterForLanguage( $languageId ) -> $memberFormatter

=cut

sub getMemberFormatterForLanguage {
    my ($inLanguage) = @_;

    require VisDoc::MemberFormatterAS2;
    if ( $inLanguage eq $VisDoc::ParserAS2::ID ) {
        my VisDoc::MemberFormatterAS2 $formatter =
          VisDoc::MemberFormatterAS2->new();
        return $formatter;
    }
    require VisDoc::MemberFormatterAS3;
    if ( $inLanguage eq $VisDoc::ParserAS3::ID ) {
        my VisDoc::MemberFormatterAS3 $formatter =
          VisDoc::MemberFormatterAS3->new();
        return $formatter;
    }
    require VisDoc::MemberFormatterJava;
    if ( $inLanguage eq $VisDoc::ParserJava::ID ) {
        my VisDoc::MemberFormatterJava $formatter =
          VisDoc::MemberFormatterJava->new();
        return $formatter;
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
