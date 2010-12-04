package VisDoc::Language;

use strict;
use warnings;
use JSON();

our $docTerms;
our $javadocTerms;

our $DEFAULT_DOC_TERM_LANGUAGE = 'default';

sub initDocTerms {
    my ($inJsonText) = @_;

    my $json = new JSON;

    # allow # comments
    $json = $json->relaxed( [1] );
    $docTerms = $json->decode($inJsonText);
}

sub getDocTerm {
    my ( $inKey, $inLanguage ) = @_;

    my $language = $inLanguage || $DEFAULT_DOC_TERM_LANGUAGE;
    my $term = $docTerms->{$inKey}->{$language};
    $term = $docTerms->{$inKey}->{$DEFAULT_DOC_TERM_LANGUAGE} if !$term;
    return $term;
}

sub initJavadocTerms {
    my ($inJsonText) = @_;

    my $json = new JSON;

    # allow # comments
    $json = $json->relaxed( [1] );
    $javadocTerms = $json->decode($inJsonText);
}

sub getJavadocTerm {
    my ($inKey) = @_;

    return $javadocTerms->{$inKey};
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
