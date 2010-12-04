package VisDoc::FormatterBase;

use strict;
use warnings;
use VisDoc::Defaults;
use VisDoc::Language;
use VisDoc::ClassData;
use VisDoc::MemberData;

our $DEFAULT_ACCESS;

=pod

=cut

sub new {
    my ($class) = @_;
    my $this = {};

    $this->{LANGUAGE} = undef;
    $this->{syntax}   = {
        keywords    => undef,
        identifiers => undef,
        properties  => undef,
    };
    bless $this, $class;
    return $this;
}

=pod

_isDefaultAccess( \@access ) -> $bool

Returns 1 if this is default access.
To be implemented by subclasses.

=cut

sub _isDefaultAccess {
    my ( $this, $inAccess ) = @_;

    return 0;
}

=pod

formatClassAccess ( $type, \@access, $listDefaultAccess ) -> $text 

$type - one of $VisDoc::ClassData::TYPE
\@access - access array
$listDefaultAccess - if true, show if default access; otherwise hide (default false)

=cut

sub formatClassAccess {
    my ( $this, $inType, $inAccess, $listDefaultAccess ) = @_;

    return '' if !$inType;
    my $type = $inType;

    my @accessItems;
    @accessItems = @{$inAccess}
      if $inAccess;

    my $isDefaultAccess = $this->_isDefaultAccess($inAccess);

    # return if this is a class with default access
    return ''
      if (!$listDefaultAccess
        && $isDefaultAccess
        && ( $type & $VisDoc::ClassData::TYPE->{'CLASS'} ) );

    # add default
    if ( !$inAccess || !( scalar @{$inAccess} ) ) {
        my $text =
          VisDoc::Language::getDocTerm( 'access_default', $this->{LANGUAGE} );
        push( @accessItems, $text ) if $text;
    }

    if ( $inType & $VisDoc::ClassData::TYPE->{'CLASS'} ) {
        my $text =
          VisDoc::Language::getDocTerm( 'classproperty_class',
            $this->{LANGUAGE} );
        push( @accessItems, $text ) if $text;
    }
    if ( $inType & $VisDoc::ClassData::TYPE->{'INTERFACE'} ) {
        my $text =
          VisDoc::Language::getDocTerm( 'classproperty_interface',
            $this->{LANGUAGE} );
        push( @accessItems, $text ) if $text;
    }

    return join( " ", @accessItems );
}

=pod

formatMethodAccess ( $type, \@access, $listDefaultAccess ) -> $text 

=$type= - one of $VisDoc::MemberData::TYPE
=\@access= - access array

=cut

sub formatMethodAccess {
    my ( $this, $inType, $inAccess, $listDefaultAccess ) = @_;

    return '' if !$inType;
    my $type = $inType;

    my @accessItems;
    @accessItems = @{$inAccess}
      if $inAccess;

    my $isDefaultAccess = $this->_isDefaultAccess($inAccess);

    # return if this is an instance member with default access
    return ''
      if (!$listDefaultAccess
        && $isDefaultAccess
        && ( $type & $VisDoc::MemberData::TYPE->{'INSTANCE_MEMBER'} ) );

    # add default
    if ( !$inAccess || !( scalar @{$inAccess} ) ) {
        my $text =
          VisDoc::Language::getDocTerm( 'access_default', $this->{LANGUAGE} );
        push( @accessItems, $text ) if $text;
    }

    my $addTermToAccessList = sub {
        my ( $inTypeKey, $inDocKey ) = @_;
        if ( $inType & $VisDoc::MemberData::TYPE->{$inTypeKey} ) {
            my $text =
              VisDoc::Language::getDocTerm( $inDocKey, $this->{LANGUAGE} );
            push( @accessItems, $text ) if $text;
        }
    };

    &$addTermToAccessList( 'CONSTRUCTOR_MEMBER', 'memberproperty_constructor' );
    push(
        @accessItems,
        VisDoc::Language::getDocTerm(
            'memberproperty_method', $this->{LANGUAGE}
        )
    ) if ( !( $inType & $VisDoc::MemberData::TYPE->{'CONSTRUCTOR_MEMBER'} ) );

    return join( " ", @accessItems );
}

=pod

formatPropertyAccess ( $type, \@access, $listDefaultAccess ) -> $text 

=cut

sub formatPropertyAccess {
    my ( $this, $inType, $inAccess, $listDefaultAccess ) = @_;

    return '' if !$inType;
    my $type = $inType;

    my @accessItems;
    @accessItems = @{$inAccess}
      if $inAccess;

    my $isDefaultAccess = $this->_isDefaultAccess($inAccess);

    # return if this is an instance member with default access
    return ''
      if (!$listDefaultAccess
        && $isDefaultAccess
        && ( $type & $VisDoc::MemberData::TYPE->{'INSTANCE_MEMBER'} ) );

    # add default
    if ( !$inAccess || !( scalar @{$inAccess} ) ) {
        my $text =
          VisDoc::Language::getDocTerm( 'access_default', $this->{LANGUAGE} );
        push( @accessItems, $text ) if $text;
    }

    my $addTermToAccessList = sub {
        my ( $inTypeKey, $inDocKey ) = @_;
        if ( $inType & $VisDoc::MemberData::TYPE->{$inTypeKey} ) {
            my $text =
              VisDoc::Language::getDocTerm( $inDocKey, $this->{LANGUAGE} );
            push( @accessItems, $text ) if $text;
        }
    };

    &$addTermToAccessList( 'CONST',     'memberproperty_const' );
    &$addTermToAccessList( 'NAMESPACE', 'memberproperty_namespace' );
    push(
        @accessItems,
        VisDoc::Language::getDocTerm(
            'memberproperty_property', $this->{LANGUAGE}
        )
    );

    return join( " ", @accessItems );
}

=pod

=cut

sub colorize {

    #my $this = $_[0]
    #my $text = $_[1]

    my @lines = split( /\n/, $_[1] );
    foreach my $line (@lines) {
        $_[0]->_colorizeLine($line);
        $_[0]->_deTokenColor($line);
    }
    $_[1] = join( "\n", @lines );
}

=pod

=cut

sub _colorizeLine {

    #my $this = $_[0]
    #my $text = $_[1]

    my $match;

    # comments
    if ( $_[1] !~ m/.*?\:(\/\/.*)/ ) {
        $match =
          $_[1] =~
s/(\/\/.*)/$VisDoc::StringUtils::STUB_COLORIZE_CODE_COMMENT_START$1$VisDoc::StringUtils::STUB_COLORIZE_CODE_COMMENT_END/g;
    }

    # if this is a comment, do not colorize any further
    return if $match;

    # numbers
    $_[1] =~
s/((&amp;#|%)*(\b[0-9]+\b))/$VisDoc::StringUtils::STUB_COLORIZE_CODE_NUMBER_START$1$VisDoc::StringUtils::STUB_COLORIZE_CODE_NUMBER_END/g;

    #keywords
    $_[1] =~
s/($_[0]->{syntax}->{keywords})/$VisDoc::StringUtils::STUB_COLORIZE_CODE_KEYWORD_START$1$VisDoc::StringUtils::STUB_COLORIZE_CODE_KEYWORD_END/g;

    #identifiers
    $_[1] =~
s/($_[0]->{syntax}->{identifiers})/$VisDoc::StringUtils::STUB_COLORIZE_CODE_IDENTIFIER_START$1$VisDoc::StringUtils::STUB_COLORIZE_CODE_IDENTIFIER_END/g;

    #properties
    $_[1] =~
s/($_[0]->{syntax}->{properties})/$VisDoc::StringUtils::STUB_COLORIZE_CODE_PROPERTY_START$1$VisDoc::StringUtils::STUB_COLORIZE_CODE_PROPERTY_END/g;

    # quotes
    use Regexp::Common qw( RE_quoted );
    my $quotedPattern = RE_quoted( -keep );
    $_[1] =~
s/$quotedPattern/$VisDoc::StringUtils::STUB_COLORIZE_CODE_STRING_START$1$VisDoc::StringUtils::STUB_COLORIZE_CODE_STRING_END/g;
}

=pod

=cut

sub _deTokenColor {

    #my $this = $_[0]
    #my $text = $_[1]

    $_[1] =~
s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_STRING_START/<span class="codeString">/go;
    $_[1] =~
s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_NUMBER_START/<span class="codeNumber">/go;
    $_[1] =~
s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_COMMENT_START/<span class="codeComment">/go;
    $_[1] =~
s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_KEYWORD_START/<span class="codeKeyword">/go;
    $_[1] =~
s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_IDENTIFIER_START/<span class="codeIdentifier">/go;
    $_[1] =~
s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_PROPERTY_START/<span class="codeProperty">/go;

    $_[1] =~ s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_STRING_END/<\/span>/go;
    $_[1] =~ s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_NUMBER_END/<\/span>/go;
    $_[1] =~ s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_COMMENT_END/<\/span>/go;
    $_[1] =~ s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_KEYWORD_END/<\/span>/go;
    $_[1] =~
      s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_IDENTIFIER_END/<\/span>/go;
    $_[1] =~
      s/$VisDoc::StringUtils::STUB_COLORIZE_CODE_PROPERTY_END/<\/span>/go;
}

=pod

=cut

sub formatLiteral {

    #my $this = $_[0]
    #my $text = $_[1]

    VisDoc::StringUtils::convertHtmlEntities( $_[1] );
    $_[1] =~ s/\n/<br \/>/go;

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
