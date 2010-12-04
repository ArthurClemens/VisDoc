package VisDoc::JavadocData;

use strict;
use warnings;
use overload ( '""' => \&as_string );

our $FIELD_DESCRIPTION = 'description';

=pod

=cut

sub new {
    my ($class) = @_;
    my $this = {};
    $this = {
        fields => undef,    # ref of list of FieldData and LinkData objects
        linkTags =>
          undef,  # ref of list of inline link tag references (LinkData objects)
        params => undef,    # ref of list of FieldData objects (param fields)
    };
    bless $this, $class;
    return $this;
}

=pod

getDescription() -> $text

Returns the javadoc description, if any.
In case multiple description fields are present, concatenates values with a space separator.

=cut

sub getDescription {
    my ($this) = @_;

    return $this->getCombinedFieldValue('description');
}

=pod

fieldsWithName( $fieldName ) -> \@fieldData

Finds FieldData objects with name $fieldName.

=cut

sub fieldsWithName {
    my ( $this, $inFieldName ) = @_;

    return undef if !$this->{fields} && !$this->{params};

    my $matchingFields;
    map { push( @{$matchingFields}, $_ ) if ( $_->{name} eq $inFieldName ); }
      @{ $this->{fields} };
    map { push( @{$matchingFields}, $_ ) if ( $_->{name} eq $inFieldName ); }
      @{ $this->{params} };

    return $matchingFields;
}

=pod
sub paramsWithName {
    my ( $this, $inParamName ) = @_;

    return undef if !$this->{params};

    my $matchingParams;
    map { push( @{$matchingFields}, $_ ) if ( $_->{name} eq $inParamName ); }
      @{ $this->{params} };

    return $matchingParams;
}
=cut

=pod

getSingleFieldWithName( $fieldName ) -> $fieldData

Finds the FieldData object with name $fieldName.

=cut

sub getSingleFieldWithName {
    my ( $this, $inFieldName ) = @_;

    my $fields = $this->fieldsWithName($inFieldName);

    return undef if !$fields;
    return $fields->[0];
}

=pod

getMultipleFieldsWithName( $fieldName ) -> \@fieldData

Finds the FieldData object with name $fieldName.

=cut

sub getMultipleFieldsWithName {
    my ( $this, $inFieldName ) = @_;

    return $this->fieldsWithName($inFieldName);
}

=pod

Returns the string of all fields with name $inFieldName.

=cut

sub getCombinedFieldValue {
    my ( $this, $inFieldName ) = @_;

    my $values;
    my $fields = $this->fieldsWithName($inFieldName);

    map { push( @{$values}, $_->{value} ); } @{$fields};
    return '' if !$values || !scalar @{$values};
    return join( ' ', @{$values} );
}

=pod

getAllFieldsGroupedByName() -> \@fields

Groups fields in a hash:

	{
		a => [field, field, field],
		b => [field, field, field],
		c => [field, field, field],
	}

Does not list params.

=cut

sub getAllFieldsGroupedByName {
    my ($this) = @_;

    my $allFields;
    map {
        my $name = $_->{name};
        push( @{ $allFields->{$name} }, $_ );
    } @{ $this->{fields} };

    return $allFields;

}

sub getLinkDataFields {
    my ($this) = @_;

    my $linkFields;
    map { push( @{$linkFields}, $_ ) if $_->isa("VisDoc::LinkData"); }
      @{ $this->{fields} };
    map { push( @{$linkFields}, $_ ) if $_->isa("VisDoc::LinkData"); }
      @{ $this->{linkTags} };

    return $linkFields;
}

sub getFields {
    my ($this) = @_;

    my $fields;
    map { push( @{$fields}, $_ ) } @{ $this->{fields} };
    map { push( @{$fields}, $_ ) } @{ $this->{params} };
    return $fields;
}

sub addField {
    my ( $this, $inField ) = @_;

    push( @{ $this->{params} }, $inField )
      if $inField->{type} == $VisDoc::FieldData::TYPE->{PARAM};
    push( @{ $this->{fields} }, $inField )
      if $inField->{type} == $VisDoc::FieldData::TYPE->{FIELD};
}

=pod

merge( $javadocData )

Merges this data with another JavadocData object.

=cut

sub merge {
    my ( $this, $inJavadocData ) = @_;

    # merge fields
    map { push( @{ $this->{fields} }, $_ ); } @{ $inJavadocData->{fields} };

    # merge linkTags
    map { push( @{ $this->{linkTags} }, $_ ); } @{ $inJavadocData->{linkTags} };

    # merge params
    map { push( @{ $this->{params} }, $_ ); } @{ $inJavadocData->{params} };
}

=pod

=cut

sub as_string {
    my ($this) = @_;

    my $str = 'JavadocData:';
    $str .= "\n\t fields=" . join( ',', @{ $this->{fields} } ) . "\n"
      if $this->{fields} and scalar @{ $this->{fields} };
    $str .= "\n\t params=" . join( ',', @{ $this->{params} } ) . "\n"
      if $this->{params} and scalar @{ $this->{params} };
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
