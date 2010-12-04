#! /usr/bin/perl -w
#
# See bottom of file for license and copyright information

use strict;
use warnings;
no warnings "once";
use Cwd 'getcwd';
use Getopt::Long;
use Pod::Usage;

BEGIN {
    my $root = Cwd::abs_path;
    unshift @INC, "$root/lib/CPAN/lib";
    unshift @INC, "$root/lib";
}

# check if we can read the right modules
eval "use VisDoc::Defaults";
if ($@) {
    print STDOUT $@;
    die;
}

# check if we can read the right module
eval "use VisDoc::OSX::CocoaUtils";
if ($@) {
    print STDOUT $@;
    die;
}

my $propertyListString = VisDoc::OSX::CocoaUtils::createPropertyListFromData(
    $VisDoc::Defaults::SETTINGS);
print STDOUT $propertyListString;

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
