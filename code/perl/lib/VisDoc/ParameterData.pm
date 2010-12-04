# See bottom of file for license and copyright information

package VisDoc::ParameterData;

use base 'VisDoc::Event::Listener';
use strict;
use warnings;

use VisDoc::FindLinksEvent;
use VisDoc::SubstituteLinkStubsEvent;

=pod

=cut

sub new {
    my ( $class, $inVarArgs, $inName, $inDataType, $inDefaultValue ) = @_;

    my VisDoc::ParameterData $this = $class->SUPER::new();

    $this->{varArgs}  = $inVarArgs;
    $this->{name}     = $inName;
    $this->{dataType} = $inDataType;
    $this->{value}    = $inDefaultValue;

    $this->addEventListener( $VisDoc::FindLinksEvent::NAME, \&onFindLinks,
        $this );
    $this->addEventListener( $VisDoc::SubstituteLinkStubsEvent::NAME,
        \&onSubstituteLinks, $this );

    bless $this, $class;
    return $this;
}

=pod

Event handler called by FileData.
Go through strings to find any references to classes, replace them with link stubs.

=cut

sub onFindLinks {
    my ( $this, $inEvent ) = @_;

    my @linkFields = qw(dataType value);
    &VisDoc::MemberData::onFindLinks( $this, $inEvent, \@linkFields );
}

sub onSubstituteLinks {
    my ( $this, $inEvent ) = @_;

    my @linkFields = qw(dataType value);
    &VisDoc::MemberData::onSubstituteLinks( $this, $inEvent, \@linkFields );
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
