# See bottom of file for license and copyright information

package VisDoc::Event::Event;

use strict;
use warnings;
use overload ( '""' => \&as_string );

=pod

Creates a new event with the name of the event handler and the source of the event.
@param inName: name of event (and name of handler function when no Delegate is used)
@param inSource:Object, (optional) source of event

=cut

sub new {
    my ( $class, $inName, $inSource ) = @_;

    my $this = {
        name   => $inName,
        source => $inSource,
    };
    bless $this, $class;
    return $this;
}

=pod

=cut

sub as_string {
    my ($this) = @_;

    my $str = 'Event:';
    $str .= "\n\t name=$this->{name}"     if $this->{name};
    $str .= "\n\t source=$this->{source}" if $this->{source};
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
