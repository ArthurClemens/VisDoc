package VisDoc::ClassData;

use strict;
use warnings;
use VisDoc::MemberData;
use VisDoc::StringUtils;
use VisDoc::Class;

use overload ( '""' => \&as_string,
			   'cmp' => \&compare
			 );

our $TYPE = {
    CLASS     => ( 1 << 1 ),
    INTERFACE => ( 1 << 2 ),
};

our $MEMBER_TYPE = {
    METHOD     => ( 1 << 1 ),
    PROPERTY   => ( 1 << 2 ),
    INNERCLASS => ( 1 << 3 ),
};

=pod

StaticMethod createUriForClass( $classpath ) -> $text

Creates a safe filename string derived from $classpath.

=cut

sub createUriForClass {
    my ($inClassPath) = @_;

    my $uri = $inClassPath;
    VisDoc::StringUtils::trimSpaces($uri);

    # replace dots and spaces with underscores
    $uri =~ s/[\. ]/_/go;

    return $uri;
}

=pod

StaticMethod typeString($typeNum) -> $typeString

=cut

sub typeString {
    my ($inType) = @_;

    my @type;
    push( @type, 'CLASS' )     if ( $inType & $TYPE->{CLASS} );
    push( @type, 'INTERFACE' ) if ( $inType & $TYPE->{INTERFACE} );

    return join( ";", @type );
}

# INSTANCE METHODS

=pod

=cut

sub new {
    my ($class) = @_;
    my $this = {
        fileData    => undef,    # ref of FileData object; set by FileParser
        name        => undef,    # class or interface name
        type        => undef,    # 'class' or 'interface'
        access      => undef,    # ref of list of access
        javadoc     => undef,    # Javadoc object
        methods     => undef,    # ref of list of MethodData objects
        properties  => undef,    # ref of list of PropertyData objects
        packageName => undef,    # name of package that holds this class
        classpath   => undef,    # name of classpath
        isAccessPublic =>
          undef,    # is this class public? set by language specific parser
        isInnerClass => undef,    # bool

        # temporary objects:
        working_contents => undef,    # class text, used to parse class members

        # references to Class objects:
        superclasses =>
          undef
        , # ref of list of Class objects (assuming multiple superclasses for each ClassData)
        interfaces => undef,    # ref of list of Class objects

        # references to other ClassData objects:
        enclosingClass =>
          undef,    # ref of (singular) enclosing ClassData, if inner class
        innerClasses => undef,    # ref of list of capsulated inner ClassData
        implementedBy =>
          undef
        , # the reverse of {interfaces}; ref of list of ClassData objects; set by post processing
        subclasses =>
          undef
        , # the reverse of {superclasses}; ref of list of ClassData objects; set by post processing
        dispatchedBy =>
          undef
        , # the reverse of @sends entries; ref of list of ClassData objects; set by post processing
    };
    bless $this, $class;
    return $this;
}

=pod

=cut

sub compare {
    my ($first, $second) = @_;
    
    return (lc $first->{'classpath'} cmp lc $second->{'classpath'});
}

=pod

=cut

sub as_string {
    my ($this) = @_;

    my $str = 'ClassData:';
    $str .= "\n\t name=$this->{name}"                  if $this->{name};
    $str .= "\n\t type=" . typeString( $this->{type} ) if $this->{type};
    $str .= "\n\t packageName=$this->{packageName}"    if $this->{packageName};
    $str .= "\n\t classpath=$this->{classpath}"        if $this->{classpath};
    $str .= "\n";
    return $str;
}

=pod

setSuperclassNames( \@superclassNames )

Stores superclass name data in Class objects, stores in {superclasses}.

=cut

sub setSuperclassNames {
    my ( $this, $inSuperclassNames ) = @_;

    map { push( @{ $this->{superclasses} }, VisDoc::Class->new($_) ); }
      @{$inSuperclassNames};
}

=pod

setInterfaceNames( \@interfaceNames )

Stores interface name data in Class objects, stores in {interfaces}.

=cut

sub setInterfaceNames {
    my ( $this, $inInterfaceNames ) = @_;

    map { push( @{ $this->{interfaces} }, VisDoc::Class->new($_) ); }
      @{$inInterfaceNames};
}

=pod

getUri( $memberName ) -> $text

Creates a safe filename string derived from the classpath.

param $member: optional name of member

=cut

sub getUri {
    my ( $this, $inMemberName ) = @_;

    my $classUri = createUriForClass( $this->{classpath} );
    $classUri .= "#$inMemberName" if $inMemberName;
    return $classUri;
}

sub getId {
    my ($this) = @_;

    return $this->{classpath};
}

sub getClasspathWithoutName {
    my ($this) = @_;

    if ( $this->{classpath} =~ m/^(.*)\.$this->{name}$/ ) {
        return $1;
    }
    else {
        return '';
    }
}

=pod

getMemberCount ( $listPrivate, $memberType ) -> $int

Counts all members of the class.

=cut

sub getMemberCount {
    my ( $this, $listPrivate, $memberType ) = @_;

    $memberType |=
      ( $MEMBER_TYPE->{METHOD} | $MEMBER_TYPE->{PROPERTY} |
          $MEMBER_TYPE->{INNERCLASS} );

    my $count = 0;
    if ($listPrivate) {
        $count += scalar @{ $this->{methods} }
          if $this->{methods} && ( $memberType & $MEMBER_TYPE->{METHOD} );
        $count += scalar @{ $this->{properties} }
          if $this->{properties} && ( $memberType & $MEMBER_TYPE->{PROPERTY} );
        $count += scalar @{ $this->{innerClasses} }
          if $this->{innerClasses}
              && ( $memberType & $MEMBER_TYPE->{INNERCLASS} );
    }
    else {

        my $mem;
        if ( $this->{methods} && ( $memberType & $MEMBER_TYPE->{METHOD} ) ) {
            foreach my $mem ( @{ $this->{methods} } ) {
                $count++ if $mem->isPublic();
            }
        }
        if ( $this->{properties} && ( $memberType & $MEMBER_TYPE->{PROPERTY} ) )
        {
            foreach my $mem ( @{ $this->{properties} } ) {
                $count++ if $mem->isPublic();
            }
        }
        if ( $this->{innerClasses}
            && ( $memberType & $MEMBER_TYPE->{INNERCLASS} ) )
        {
            foreach my $mem ( @{ $this->{innerClasses} } ) {
                $count++ if $mem->isPublic();
            }
        }
    }
    return $count;
}

=pod

getMembers () -> \@memberData

Returns a list ref of properties and methods.

=cut

sub getMembers {
    my ($this) = @_;

    my @members = ();
    push @members, @{ $this->{properties} } if $this->{properties};
    push @members, @{ $this->{methods} }    if $this->{methods};

    return \@members;
}

=pod

getConstructors () -> \@methodData

Returns a list ref of constructors.

=cut

sub getConstructors {
    my ($this) = @_;

    my @constructors =
      grep { $_->{type} & $VisDoc::MemberData::TYPE->{'CONSTRUCTOR_MEMBER'} }
      @{ $this->{methods} };
    return \@constructors;
}

=pod

getNamespaces () -> \@memberData

Returns a list ref of namespace members.

=cut

sub getNamespaces {
    my ($this) = @_;

    my @namespaces =
      grep { $_->{type} & $VisDoc::MemberData::TYPE->{'NAMESPACE'} }
      @{ $this->{properties} };
    return \@namespaces;
}

=pod

getNamespaces () -> \@memberData

=cut

sub getInnerClasses {
    my ($this) = @_;

    return $this->{innerClasses};
}

=pod

getNamespaces () -> \@memberData

=cut

sub getConstants {
    my ($this) = @_;

    my @constants =
      grep { $_->{type} & $VisDoc::MemberData::TYPE->{'CONST'} }
      @{ $this->{properties} };
    return \@constants;
}

=pod

getMemberWithQualifiedName( $name ) -> $memberData

Returns MemberData object with name $name

=cut

sub getMemberWithQualifiedName {
    my ( $this, $inQualifiedName ) = @_;

    my $methods;
    @{$methods} =
      grep { $_->getName() eq $inQualifiedName } @{ $this->{methods} };
    return $methods->[0] if scalar @{$methods};

    my $properties;
    @{$properties} =
      grep { $_->getName() eq $inQualifiedName } @{ $this->{properties} };
    return $properties->[0] if scalar @{$properties};

    return undef;
}

sub getMemberWithName {
    my ( $this, $inName ) = @_;

    my $methods;
    @{$methods} = grep { $_->{name} eq $inName } @{ $this->{methods} };
    return $methods->[0] if scalar @{$methods};

    my $properties;
    @{$properties} = grep { $_->{name} eq $inName } @{ $this->{properties} };
    return $properties->[0] if scalar @{$properties};

    return undef;
}

=pod

getClassProperties () -> \@propertyData

Returns a list ref of class properties.

=cut

sub getClassProperties {
    my ($this) = @_;

    my @classProperties = grep {
        $_->{type} & $VisDoc::MemberData::TYPE->{'CLASS_MEMBER'}
          && !( $_->{type} & $VisDoc::MemberData::TYPE->{'CONST'} )
    } @{ $this->{properties} };
    return \@classProperties;
}

=pod

getInstanceProperties () -> \@propertyData

Returns a list ref of instance properties.

=cut

sub getInstanceProperties {
    my ($this) = @_;

    my @instanceProperties =
      grep { $_->{type} & $VisDoc::MemberData::TYPE->{'INSTANCE_MEMBER'} }
      @{ $this->{properties} };
    return \@instanceProperties;
}

=pod

getClassMethods () -> \@methodData

Returns a list ref of class methods.

=cut

sub getClassMethods {
    my ($this) = @_;

    my @classMethods =
      grep { $_->{type} & $VisDoc::MemberData::TYPE->{'CLASS_MEMBER'} }
      @{ $this->{methods} };
    return \@classMethods;
}

=pod

getInstanceMethods () -> \@methodData

Returns a list ref of instance methods.

=cut

sub getInstanceMethods {
    my ($this) = @_;

    my @instanceMethods = grep {
        $_->{type} & $VisDoc::MemberData::TYPE->{'INSTANCE_MEMBER'}
          && !( $_->{type} & $VisDoc::MemberData::TYPE->{'CONSTRUCTOR_MEMBER'} )
    } @{ $this->{methods} };
    return \@instanceMethods;
}

=pod

isPublic() -> $bool

The class is public if javadoc does not have a field 'private', and if access is public.

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

sub isExcluded {
    my ($this) = @_;

    return 1
      if $this->{javadoc}
          && $this->{javadoc}->getSingleFieldWithName('exclude')
    ;    # overrides class access

    return 0;
}

=pod

getSuperclassChain() -> \@superclasses

Creates a chain of superclass Class objects.

=cut

sub getSuperclassChain {
    my ($this) = @_;

    my @superclassChain = ();
    $this->_chainSuperclassesOrInterfaces( \@superclassChain,
        $this->{superclasses} );
    return \@superclassChain;
}

=pod

getSuperInterfaceChain() -> \@superclasses

Creates a chain of superclass Class objects.

=cut

sub getSuperInterfaceChain {
    my ($this) = @_;

    my @superInterfaceChain = ();
    $this->_chainSuperclassesOrInterfaces( \@superInterfaceChain,
        $this->{interfaces} );

    return \@superInterfaceChain;
}

=pod

_chainSuperclassesOrInterfaces( \@superclassChain, \@superclasses )

Recursive function that adds superclass Class objects to array @superclassChain.

=cut

sub _chainSuperclassesOrInterfaces {
    my ( $this, $inChain, $inSuper ) = @_;

    foreach my $super ( @{$inSuper} ) {
        push( @{$inChain}, $super );
        next if !$super->{classdata};
        my $superSuper = $super->{classdata}->{superclasses};
        if ($superSuper) {
            $this->_chainSuperclassesOrInterfaces( $inChain, $superSuper );
        }
    }
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
