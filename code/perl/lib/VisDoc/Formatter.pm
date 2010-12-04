package VisDoc::Formatter;

use strict;
use warnings;
use VisDoc::FormatterBase;
use VisDoc::FormatterAS2;
use VisDoc::FormatterAS3;
use VisDoc::FormatterJava;

our VisDoc::FormatterAS2 $FORMATTER_AS2;
our VisDoc::FormatterAS3 $FORMATTER_AS3;
our VisDoc::FormatterJava $FORMATTER_JAVA;

=pod

StaticMethod formatter ($language ) -> $formatter

Formatter factory method.

$language: language id

my $formatter = VisDoc::Formatter::formatter( $language );

=cut

sub formatter {
    my ($inLanguage) = @_;

    if ( $inLanguage eq 'as2' ) {
        $FORMATTER_AS2 = VisDoc::FormatterAS2->new() if !$FORMATTER_AS2;
        return $FORMATTER_AS2;
    }
    if ( $inLanguage eq 'as3' ) {
        $FORMATTER_AS3 = VisDoc::FormatterAS3->new() if !$FORMATTER_AS3;
        return $FORMATTER_AS3;
    }
    if ( $inLanguage eq 'java' ) {
        $FORMATTER_JAVA = VisDoc::FormatterJava->new() if !$FORMATTER_JAVA;
        return $FORMATTER_JAVA;
    }

    die "No formatter found for language $inLanguage";
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
