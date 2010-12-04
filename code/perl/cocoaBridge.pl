#! /usr/bin/perl -w
#
# See bottom of file for license and copyright information

use strict;
use warnings;

use Cwd 'getcwd';
use Getopt::Long;
use Pod::Usage;

# Show help
Getopt::Long::Configure( "no_auto_abbrev", "no_ignore_case" );

sub usage {
    pod2usage( { -verbose => 2, -input => \*DATA } );
    exit;
}
usage() if ( scalar @ARGV == 0 );

BEGIN {
    my $root = Cwd::abs_path;
    unshift @INC, "$root/lib/CPAN/lib";
    unshift @INC, "$root/lib";
}

# parse command line options
my $dataPath        = '';
my $extensions      = '';
my $defaults        = '';
my $files           = '';
my $ignorePathNames = '';
my $help            = 0;
my $feedback        = 0;
&GetOptions(
    'datapath=s'   => \$dataPath,
    'extensions=s' => \$extensions,
    'files=s'      => \$files,
    'ignorepath:s' => \$ignorePathNames,
    'help'         => \$help,
    'feedback'     => \$feedback,
);
usage() if $help;

my $validExtensions;
if ($extensions) {
    map { $validExtensions->{$_} = 1; } split( /\s*,\s*/, $extensions );
}

$ignorePathNames ||= '.svn';
my $ignorePaths;
if ($ignorePathNames) {
    map { $ignorePaths->{$_} = 1; } split( /\s*,\s*/, $ignorePathNames );
}

my $doValidate = 1;

if ($files) {

    # check if we can read the right modules
    eval "use VisDoc";
    if ($@) {
        print STDOUT $@;
        die;
    }
    eval "use VisDoc::FileUtils";
    if ($@) {
        print STDOUT $@;
        die;
    }
    eval "use VisDoc::OSX::CocoaUtils";
    if ($@) {
        print STDOUT $@;
        die;
    }

    my $out = '';

    my $argFiles = $files;

    # remove escaped spaces
    $argFiles =~ s/\\ / /go;
    my @inputFileList = split( /\s*,\s*/, $argFiles );

    my $fileInfo    = {};
    my $listedFiles = {};
    my $listedDirs  = {};
    foreach my $path (@inputFileList) {

        # make sure path does not have a trailing slash
        $path =~ s/^(.*?)\/*$/$1/;

        if ( -f $path ) {
            if ( defined $validExtensions ) {
                my @parts = split( /\./, $path );
                my $extension = pop @parts;
                next if !( $validExtensions->{$extension} );
            }
            if ($doValidate) {
                my $fileInfo = VisDoc::validateFile($path);
                $listedFiles->{$path} = $fileInfo->{valid};
            }
            else {
                $listedFiles->{$path} = 1;
            }
        }
        if ( -d $path ) {
            my @tmpList = ($path);
            my $files =
              VisDoc::FileUtils::getFiles( \@tmpList, $validExtensions,
                $ignorePaths );

            if ($doValidate) {
                my $validCount = 0;
                foreach my $file ( @{$files} ) {
                    my $fileInfo = VisDoc::validateFile($file);
                    $validCount++ if $fileInfo->{valid};
                }
                $listedDirs->{$path} = $validCount;
            }
            else {
                $listedDirs->{$path} = scalar @{$files};
            }
        }

    }

    # remove zero counts
    my $inValidListedFiles = {};
    my $inValidListedDirs  = {};

    while ( ( my $path, my $value ) = each %{$listedFiles} ) {
        if ( $value == 0 ) {
            $inValidListedFiles->{$path} = 0;
            delete $listedFiles->{$path};
        }
    }
    while ( ( my $path, my $value ) = each %{$listedDirs} ) {
        if ( $value == 0 ) {
            $inValidListedDirs->{$path} = 0;
            delete $listedDirs->{$path};
        }
    }
    if ( scalar keys %{$inValidListedFiles} ) {
        my $invalidListedFilesString =
          VisDoc::OSX::CocoaUtils::createPropertyListFromData(
            $inValidListedFiles);
        $out .= "invalidListedFiles=$invalidListedFilesString;\n";
    }
    if ( scalar keys %{$inValidListedDirs} ) {
        my $invalidListedDirsString =
          VisDoc::OSX::CocoaUtils::createPropertyListFromData(
            $inValidListedDirs);
        $out .= "invalidListedDirs=$invalidListedDirsString;\n";
    }

    if ( scalar keys %{$listedFiles} ) {
        my $validListedFilesString =
          VisDoc::OSX::CocoaUtils::createPropertyListFromData($listedFiles);
        $out .= "validListedFiles=$validListedFilesString;\n";
    }
    if ( scalar keys %{$listedDirs} ) {
        my $validListedDirsString =
          VisDoc::OSX::CocoaUtils::createPropertyListFromData($listedDirs);
        $out .= "validListedDirs=$validListedDirsString;\n";
    }
    my $validFileCount = scalar keys %{$listedFiles};
    my $validDirCount  = scalar keys %{$listedDirs};
    $out .=
"counts={\nvalidFileCount = $validFileCount;\nvalidDirCount = $validDirCount;\n};\n";

    VisDoc::OSX::CocoaUtils::writeOut( $out, $dataPath );
    exit;
}

1;

__DATA__

=head1 SYNOPSIS

Get file info on the list of path strings. Returns data as Mac OS X Cocoa dictionary.
 
=head1 USAGE

cocoaBridge.pl [options]

=head1 OPTIONS

=over 8

=item B<-help>

Shows this help text

=item B<-files> [files1,file2,...]

Comma-separated list of file paths to get info on.
For example:
perl cocoaBridge.pl -files "test/unit/testfiles/testcode_as3.as,test/unit/testfiles/testlanguage_as3.as"

=item B<-extensions> [extension1,extension2,...]

Comma-separated list of file extensions. Only files with those file extensions will used.

For example:
perl cocoaBridge.pl -files "test/unit/testfiles/" -extensions as

=item B<-ignorepath> [name1,name2,...]

(Parts) of file paths that should be ignored. By default '.svn' paths are ignored.

=item B<-datapath> [path]

Filepath to write output to. If not used, output is written to the terminal.

=cut




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
