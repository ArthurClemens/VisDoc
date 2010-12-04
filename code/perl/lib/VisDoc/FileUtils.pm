package VisDoc::FileUtils;

use strict;
use warnings;
use File::stat();
use File::Find();
use File::Spec();
use Cwd 'getcwd';

=pod

getFiles( \@filesAndDirs, \%validExtensions, \%ignorePaths ) -> \@filesList

Reads in an list of files and dirs.
Returns a list of all files within those files and dirs.

param \%validExtensions: optional
param \%ignorePaths: optional

=cut

sub getFiles {
    my ( $inputFilesAndDirs, $validExtensions, $ignorePaths ) = @_;

    return undef if !$inputFilesAndDirs || !( scalar @{$inputFilesAndDirs} );

    # remove files that do not exist
    my @fileList;
    foreach my $file ( @{$inputFilesAndDirs} ) {
        next if !$file;
        if ($ignorePaths) {
            while ( ( my $ignorePath, my $unused ) = each %{$ignorePaths} ) {
                next if $file =~ m/$ignorePath/;
            }
        }
        next if !( -e $file );
        push( @fileList, $file );
    }

    return undef if !scalar @fileList;

    my $files;
    my $wanted = sub {
        my ( $volume, $directories, $file ) =
          File::Spec->splitpath($File::Find::name);
        return if !$file;
        return if $file =~ /^\..*?$/;
        return if !( $file =~ /\./ );
        if ($validExtensions) {
            my @parts = split( /\./, $file );
            my $extension = pop @parts;
            return if !( $validExtensions->{$extension} );
        }
        if ($ignorePaths) {
            my %ignore = %{$ignorePaths};
            while ( ( my $ignorePath, my $unused ) = each %ignore ) {
                if ( $directories =~ m/$ignorePath/ ) {
                    return;
                }
                if ( $file =~ m/$ignorePath/ ) {
                    return;
                }
            }
        }
        push @{$files}, $File::Find::name;
    };
    File::Find::find( \&$wanted, @fileList );

    my $base = getcwd();
    foreach my $file ( @{$files} ) {
        $file = File::Spec->rel2abs( $file, $base );
    }

    return $files;
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
