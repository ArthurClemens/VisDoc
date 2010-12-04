package VisDoc::Class;

use strict;
use warnings;
use VisDoc::ClassData;

use overload ( '""' => \&as_string );

=pod

=cut

sub new {
    my ( $class, $inName ) = @_;

    my $name      = undef;
    my $classpath = undef;
    if ( $inName =~ m/(.*)\.(.*?)$/ ) {
        $name      = $2;
        $classpath = $inName;
    }
    else {
        $name = $inName;
    }
    my $this = {
        name      => $name      || undef,    # class or interface name
        classpath => $classpath || undef,    # package name plus class name
        classdata => undef,                  # ref to ClassData object
    };
    bless $this, $class;
    return $this;
}

sub as_string {
    my ($this) = @_;

    my $str = 'Class:';
    $str .= "\n\t name=$this->{name}"           if $this->{name};
    $str .= "\n\t classpath=$this->{classpath}" if $this->{classpath};
    $str .= "\n\t classdata=$this->{classdata}" if $this->{classdata};
    $str .= "\n";
    return $str;
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
