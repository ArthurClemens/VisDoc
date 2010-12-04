# See bottom of file for license and copyright information

package VisDoc::PackageData;

use strict;
use warnings;
use VisDoc::StringUtils;

use overload ( '""' => \&as_string );

our $MEMBER_TYPE = {
    CLASS    => ( 1 << 1 ),
    FUNCTION => ( 1 << 2 ),
};

=pod

StaticMethod createUriForPackage( $name ) -> $text

Creates a safe filename string derived from $name.

=cut

sub createUriForPackage {
    my ($inName) = @_;

    my $uri = "package_$inName";
    VisDoc::StringUtils::trimSpaces($uri);

    # change dots and spaces to underscores
    $uri =~ s/[\. ]/_/go;

    return $uri;
}

=pod

=cut

sub new {
    my ($class) = @_;
    my $this = {
        fileData  => undef,    # ref of FileData object; set by FileParser
        name      => '',
        anonymous => 0,        # is anonymous package: true (1) or false (0)
        access    => undef,    # ref of list of access, not used
        classes   => undef,
        functions => undef,    # ref of list of MethodData objects
        javadoc   => undef,    # JavaDoc object
    };
    bless $this, $class;
    return $this;
}

=pod

getUri() -> $text

Creates a safe filename string derived from the name. Calls createUriForPackage.

=cut

sub getUri {
    my ($this) = @_;

    return createUriForPackage( $this->{name} );
}

=cut

=pod

getMemberCount ($listPrivate, $memberType) -> $int

Counts all classes and functions of the package.

param $listPrivate: 

=cut

sub getMemberCount {
    my ( $this, $listPrivate, $memberType ) = @_;

    $memberType |= ( $MEMBER_TYPE->{CLASS} | $MEMBER_TYPE->{FUNCTION} );

    my $count = 0;
    if ($listPrivate) {
        $count += scalar @{ $this->{classes} }
          if $this->{classes} && ( $memberType & $MEMBER_TYPE->{CLASS} );
        $count += scalar @{ $this->{functions} }
          if $this->{functions} && ( $memberType & $MEMBER_TYPE->{FUNCTION} );
    }
    else {

        my $mem;
        if ( $this->{classes} && ( $memberType & $MEMBER_TYPE->{CLASS} ) ) {
            foreach my $mem ( @{ $this->{classes} } ) {
                $count++ if $mem->isPublic();
            }
        }
        if ( $this->{functions} && ( $memberType & $MEMBER_TYPE->{FUNCTION} ) )
        {
            foreach my $mem ( @{ $this->{functions} } ) {
                $count++ if $mem->isPublic();
            }
        }
    }

    return $count;
}

sub getClasses {
    my ($this) = @_;

    return $this->{classes};
}

sub getFunctions {
    my ($this) = @_;

    return $this->{functions};
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

isPublic() -> $bool

The class is public if javadoc does not have a field 'private', and if access is public.

=cut

sub isPublic {
    my ($this) = @_;

    return 1;
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

=cut

sub as_string {
    my ($this) = @_;

    my $str = 'PackageData:';
    $str .= "\n\t name=$this->{name}"           if $this->{name};
    $str .= "\n\t anonymous=$this->{anonymous}" if $this->{anonymous};
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
