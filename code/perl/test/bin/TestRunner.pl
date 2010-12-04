#!/usr/bin/perl -w
# See bottom of file for description

require 5.006;
use FindBin;
use Cwd ();

sub _findRelativeTo {
    my ( $startdir, $name ) = @_;

    my @path = split( /\/+/, $startdir );

    while ( scalar(@path) > 0 ) {
        my $found = join( '/', @path ) . '/' . $name;
        return $found if -e $found;
        pop(@path);
    }
    return undef;
}

BEGIN {
    # root the tree
    my $here = Cwd::abs_path;
    my $root = _findRelativeTo( $here, '..' );
    
    unshift @INC, "$root/test/unit";
    unshift @INC, "$root/bin";
    unshift @INC, "$root/lib";
    unshift @INC, "$root/../lib";
    unshift @INC, "$root/../lib/CPAN/lib";
};

use strict;
use Unit::TestRunner;

my %options;
while (scalar(@ARGV) && $ARGV[0] =~ /^-/) {
    $options{shift(@ARGV)} = 1;
}

my ($stdout, $stderr, $log); # will be destroyed at the end, if created
if ($options{-log}) {
    require Unit::Eavesdrop;
    my @gmt = gmtime(time());
    $gmt[4]++;
    $gmt[5] += 1900;
    $log = sprintf("%0.4d",$gmt[5]);
    for (my $i = 4; $i >= 0; $i--) {
        $log .= sprintf("%0.2d", $gmt[$i]);
    }
    $log .= '.log';
    open(F, ">$log") || die $!;
    print STDERR "Logging to $log\n";
    $stdout = new Unit::Eavesdrop('STDOUT');
    $stdout->teeTo(\*F);
}
print STDERR "Options: ",join(' ',keys %options),"\n";

if ($options{-clean}) {
    require File::Path;
}


my $testrunner = Unit::TestRunner->new();
my $exit = $testrunner->start(@ARGV);

print STDERR "Run was logged to $log\n" if $options{-log};

exit $exit;

sub testForFiles {
    my $test = shift;
    my @list = glob $test;
    die "Please remove $test (or run with the -clean option) to run tests\n" if (scalar(@list));
}

1;

__DATA__

This script runs the test suites/cases defined on the command-line.

Author: Crawford Currie, http://c-dot.co.uk

Copyright (C) 2007 WikiRing, http://wikiring.com
All Rights Reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
