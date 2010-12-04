package VisDoc::FormatterJava;
use base 'VisDoc::FormatterBase';

use strict;
use warnings;

=pod

=cut

sub new {
    my ($class) = @_;
    my VisDoc::FormatterJava $this = $class->SUPER::new();

    $this->{LANGUAGE} = 'java';
    $this->{syntax}   = {
        keywords =>
'\bwhile\b|\bvolatile\b|\bvoid\b|\btry\b|\btransient\b|\bthrows\b|\bthrow\b|\bthis\b|\bsynchronized\b|\bswitch\b|\bsuper\b|\bstrictfp\b|\bstatic\b|\bshort\b|\breturn\b|\bpublic\b|\bprotected\b|\bprivate\b|\bpackage\b|\bnew\b|\bnative\b|\blong\b|\binterface\b|\bint\b|\binstanceof\b|\bimport\b|\bimplements\b|\bif\b|\bgoto\b|\bfor\b|\bfloat\b|\bfinally\b|\bfinal\b|\bextends\b|\benum\b|\belse\b|\bdouble\b|\bdo\b|\bdefault\b|\bcontinue\b|\bconst\b|\bclass\b|\bchar\b|\bcatch\b|\bcase\b|\bbyte\b|\bbreak\b|\bboolean\b|\bassert\b|\babstract\b',
        identifiers => '',
        properties  => '',
    };
    bless $this, $class;
    return $this;
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
