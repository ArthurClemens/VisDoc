# See bottom of file for license and copyright information

package VisDoc::MemberData;

use strict;
use warnings;
use overload ( '""' => \&as_string );

=pod

Defined by subclass.

=cut

our $TYPE = {
    READ               => ( 1 << 1 ),
    WRITE              => ( 1 << 2 ),
    CONST              => ( 1 << 3 ),
    NAMESPACE          => ( 1 << 4 ),
    CONSTRUCTOR_MEMBER => ( 1 << 5 ),
    CLASS_MEMBER       => ( 1 << 6 ),
    INSTANCE_MEMBER    => ( 1 << 7 ),
};

=pod

=cut

sub new {
    my ($class) = @_;
    my $this = {};
    $this = {
        _id         => undef,    # unique id for each type (a method and a property can have the same id)
        memberOrder => undef,    # int
        type =>
          undef
        ,  # values of $TYPE (bitwise operator); undef if not a getter or setter
        name          => undef,    # string
        qualifiedName => undef,    # string (NOT USED YET)
        nameId => undef, # string, unique identifier name, created after parsing
        access =>
          undef,  # ref of list of access strings (public, private, static, ...)
        javadoc  => undef,    # JavaDoc object
        metadata => undef,    # ref of list of MetaData objects
        isAccessPublic =>
          undef,    # is this member public? set by language specific parser
    };
    bless $this, $class;
    return $this;
}

=pod

onFindLinks( $event, \@linkFields ) 

Event handler called by FileData.
Go through strings to find any references to classes, replace them with link stubs.

=cut

sub onFindLinks {
    my ( $this, $inEvent, $inLinkFields ) = @_;

    my $callback = $inEvent->{callback};
    foreach my $field ( @{$inLinkFields} ) {
        if ( $this->{$field} ) {
            foreach my $class ( @{ $inEvent->{classes} } ) {

                # replace
                $this->{$field} =~
                  s/(\b$class->{name}\b)/$inEvent->{source}->$callback($1)/e;
            }
        }
    }
}

sub onSubstituteLinks {
    my ( $this, $inEvent, $inLinkFields ) = @_;

    my $callback = $inEvent->{callback};
    foreach my $field ( @{$inLinkFields} ) {
        if ( $this->{$field} ) {

            #foreach my $class ( @{ $inEvent->{classes} } ) {
            $this->{$field} = $inEvent->{source}->$callback( $this->{$field} );

            #}
        }
    }
}

=pod

isPublic() -> $bool

The member is public if javadoc does not have a field 'private', and if access is public.

=cut

sub isPublic {
    my ($this) = @_;

    return 0
      if $this->{javadoc}
          && $this->{javadoc}->getSingleFieldWithName('private')
    ;    # overrides class access
    return 1 if $this->{isAccessPublic};
    return 0;
}

sub getId {
    my ($this) = @_;

    my $id = $this->{nameId} || $this->{name};
    return $id;
}

sub getName {
    my ($this) = @_;

    return $this->{name};    #$this->{qualifiedName} || $this->{name};
}

sub isExcluded {
    my ($this) = @_;

    return 1
      if $this->{javadoc}
          && $this->{javadoc}->getSingleFieldWithName('exclude')
    ;                        # overrides class access

    return 0;
}

sub setNameId {
    my ( $this, $inNameId ) = @_;

    $this->{nameId} = $inNameId;
}

sub setJavadoc {
    my ( $this, $inJavadocData ) = @_;

    if ( $this->{javadoc} ) {
        $this->{javadoc}->merge($inJavadocData);
    }
    else {
        $this->{javadoc} = $inJavadocData;
    }
}

=pod

StaticMethod typeString($typeNum) -> $typeString

=cut

sub typeString {
    my ($inType) = @_;

    my @type;
    push( @type, 'READ' )      if ( $inType & $TYPE->{READ} );
    push( @type, 'WRITE' )     if ( $inType & $TYPE->{WRITE} );
    push( @type, 'CONST' )     if ( $inType & $TYPE->{CONST} );
    push( @type, 'NAMESPACE' ) if ( $inType & $TYPE->{NAMESPACE} );
    push( @type, 'CONSTRUCTOR_MEMBER' )
      if ( $inType & $TYPE->{CONSTRUCTOR_MEMBER} );
    push( @type, 'CLASS_MEMBER' )    if ( $inType & $TYPE->{CLASS_MEMBER} );
    push( @type, 'INSTANCE_MEMBER' ) if ( $inType & $TYPE->{INSTANCE_MEMBER} );

    return join( ";", @type );
}

=pod

Returns false if $access contains the string 'override(false)'.
Returns true if $access contains the string 'override', 'override(true)' or 'override(undefined)'.
Returns false if $access does not contain 'override'.

=cut

sub overrides {
    my ($this) = @_;

    return 0 if ( !scalar @{ $this->{access} } );
    my $access = join( ',', @{ $this->{access} } );
    $access =~ s/ //g;
    return 0 if $access =~ m/\boverride\b\(\bfalse\b\)/i;
    return 1 if $access =~ m/\boverride\b/i;
    return 0;
}

sub as_string {
    my ($this) = @_;

    my $str = 'MemberData:';
    $str .= "\n\t name=$this->{name}"                  if $this->{name};
    $str .= "\n\t nameId=$this->{nameId}"              if $this->{nameId};
    $str .= "\n\t type=" . typeString( $this->{type} ) if $this->{type};
    $str .= "\n\t access=" . join( ',', @{ $this->{access} } )
      if $this->{access};
    $str .= "\n\t memberOrder=$this->{memberOrder}"
      if $this->{memberOrder};
    $str .= "\n\t _id=$this->{_id}" if $this->{_id};

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
