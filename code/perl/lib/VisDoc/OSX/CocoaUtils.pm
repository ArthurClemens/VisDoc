# See bottom of file for license and copyright information

package VisDoc::OSX::CocoaUtils;

use strict;
use warnings;

=pod

createPropertyListFromData( \%data, $key ) -> $propertyListString

param $key is optional

=cut

sub createPropertyListFromData {
    my ( $inData, $inKey ) = @_;

    my $key               = $inKey ? "$inKey = " : '';
    my $itemSeparator     = ' = ';
    my $keyValueSeparator = '; ';
    my @list              = ();

    while ( my ( $ikey, $ivalue ) = each %{$inData} ) {
        $ivalue = '' if !$ivalue;
        $ivalue =~ s/\"/\\"/go;    # escape quotes
        push @list, "\"$ikey\"$itemSeparator\"$ivalue\";";
    }
    my $propertyList = "$key\{\n" . join( "\n", @list ) . "\n}";
    return $propertyList;
}

=pod

writeOut( $text, $path )

Writes $text to file at $path, or to STDOUT if no path is given.

=cut

sub writeOut {
    my ( $inText, $inPath ) = @_;

    if ($inPath) {
        eval "use File::Slurp qw(write_file)";
        if ($@) {
            print STDOUT $@;
            die;
        }
        File::Slurp::write_file( $inPath, { atomic => 1 }, $inText );
    }
    else {
        print STDOUT $inText;
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
