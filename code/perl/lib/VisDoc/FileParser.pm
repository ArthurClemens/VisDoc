package VisDoc::FileParser;

use strict;
use warnings;
use VisDoc;
use VisDoc::FileData;
use VisDoc::StringUtils;
use VisDoc::ParserBase;
use VisDoc::ParserJava;
use VisDoc::ParserAS2;
use VisDoc::ParserAS3;
use VisDoc::JavadocParser;
use VisDoc::PackageData;

=pod

StaticMethod getLanguageId($path, $text) -> $languageId

Guesses the language of a program text file from $inFilePath.
If this cannot be guessed (.as may be AS2 or AS3), the language is derived from the file text $inText.

The code does not check if the file at $path exists.

Language IDs:
- Java: java
- ActionScript 2: $ID_AS2
- ActionScript 3: $ID_AS3

=cut

sub getLanguageId {
    my ( $inFilePath, $inText ) = @_;

    my $id;

    # test for java
    $id = VisDoc::ParserJava::getLanguageId($inFilePath);
    return $id if $id;

    # if not java
    my $cleanText = $inText;    # do not touch original text
                                # remove comments text
    VisDoc::StringUtils::stripAllComments($cleanText);

    # test for as3
    $id = VisDoc::ParserAS3::getLanguageId($cleanText);
    return $id if $id;

    # if not as3
    # test for as2
    $id = VisDoc::ParserAS2::getLanguageId($cleanText);
    return $id if $id;

    # else: unknown language
    return undef;
}

=pod

StaticMethod _getFileInfo($path) -> ($modificationDate) 

=cut

sub _getFileInfo {
    my ($inFilePath) = @_;

    my $modificationDate = ( stat($inFilePath) )[9];

    return ($modificationDate);
}

### INSTANCE MEMBERS ###

=pod

=cut

sub new {
    my ($class) = @_;
    my $this = { data => VisDoc::FileData->new() };
    bless $this, $class;
    return $this;
}

=pod

getFileData( $path, $languageId ) -> ($fileData, $fileText)

param $path
param $languageId (optional)

=cut

sub getFileData {
    my ( $this, $inPath, $inLanguageId ) = @_;

    my ($modificationDate) = _getFileInfo($inPath);
    my $fileText           = VisDoc::readFile($inPath);
    my $text               = _cleanText($fileText);

    my $languageId = $inLanguageId || getLanguageId( $inPath, $text );
    my $fileData = $this->{data};
    $fileData->{language}         = $languageId;
    $fileData->{path}             = $inPath;
    $fileData->{modificationDate} = $modificationDate;

    return ( $fileData, $fileText );
}

=pod

parseFile( $path, $languageId ) -> $fileData

param $path
param $languageId (optional)

=cut

sub parseFile {
    my ( $this, $inPath, $inLanguageId ) = @_;

    my ( $fileData, $fileText ) = $this->getFileData( $inPath, $inLanguageId );

    my $languageId = $fileData->{language} || getLanguageId( undef, $fileText );
    return undef if !$languageId;

    $this->{data} = $fileData;
    $this->parseText( $fileText, $languageId );

    return $this->{data};
}

=pod

parseText ( $text, $languageId ) -> $fileData

=cut

sub parseText {
    my ( $this, $inText, $inLanguageId ) = @_;

    my $text = _cleanText($inText);

    my $languageId = $inLanguageId || getLanguageId( undef, $text );
    return undef if !$languageId;

    $this->{data}->{language} = $languageId;

    $text = $this->_prepareForParsing($text);

    my $parser = $this->getParserForLanguage($languageId);

    # recursively handle included files
    my $textHasChanged = 1;
    while ($textHasChanged) {
        my $beforeText = $text;
        $text           = $parser->resolveIncludes($text);
        $text           = $this->_prepareForParsing($text);
        $textHasChanged = ( $beforeText ne $text );
    }

    my ( $classes, $remainingText ) = $parser->parseClasses($text);

    my $packageData =
      $parser->parsePackage( $this->{data}, $remainingText, $languageId,
        $classes );
    my @packages = ($packageData);
    $this->{data}->{packages} = \@packages;

    # store the file data in each class
    $this->{data}->{modificationDate} = time()
      if !$this->{data}->{modificationDate};
    map { $_->{fileData} = $this->{data} } @$classes;
    map { $_->{fileData} = $this->{data} } @packages;

    return $this->{data};
}

=pod

getParserForLanguage($languageId) -> $parser

Class method that creates a new specific parser for a language.

=cut

sub getParserForLanguage {
    my ( $this, $inLanguage ) = @_;

    require VisDoc::ParserAS2;
    if ( $inLanguage eq $VisDoc::ParserAS2::ID ) {
        my VisDoc::ParserAS2 $parser = VisDoc::ParserAS2->new($this);
        return $parser;
    }
    require VisDoc::ParserAS3;
    if ( $inLanguage eq $VisDoc::ParserAS3::ID ) {
        my VisDoc::ParserAS3 $parser = VisDoc::ParserAS3->new($this);
        return $parser;
    }
    require VisDoc::ParserJava;
    if ( $inLanguage eq $VisDoc::ParserJava::ID ) {
        my VisDoc::ParserJava $parser = VisDoc::ParserJava->new($this);
        return $parser;
    }
}

=pod

_prepareForParsing( $text) -> $text

=cut

sub _prepareForParsing {
    my ( $this, $inText ) = @_;

    my $text = $inText;
    $text = _cleanText($text);
    $this->_handleImageTags($text);
    $text = $this->_stubAllTags($text);

    return $text;
}

=pod

StaticMethod _cleanText( $text) -> $text

Cleans up text

=cut

sub _cleanText {
    my ($inText) = @_;

    my $text = $inText;
    VisDoc::StringUtils::replaceBackslashR($text);
    VisDoc::StringUtils::replaceCDATATags($text);
    VisDoc::StringUtils::stripEmptyMultilineComments($text);

    return $text;
}

=pod

=cut

sub _stubAllTags {
    my ( $this, $inText ) = @_;

    my $text = $inText;

    # put <code>...</code> and {@code ...} in hash and replace by stubs
    $text = $this->_stubCode($text);

    # put {@literal ...} in hash and replace by stubs
    $text = $this->_stubLiteralTags($text);

    # put {@link ...} in hash and replace by stubs
    $text = $this->_stubLinkTags($text);
    
    # put http:// links in hash and replace by stubs
    $text = $this->_stubUrls($text);

    # put /**...*/ and /**<..*/ in hash and replace by stubs
    $text = $this->_stubJavadocComments($text);

    VisDoc::StringUtils::stripAllComments($text);

    # put "..." and '...' in hash and replace by stubs
    $text = $this->_stubQuotedStrings($text);

    return $text;
}

=pod

=cut

sub _stubTags {

    #my $this = $_[0]
    #my $textRef = $_[1]
    #my $pattern = $_[2]
    #my $contentIndex = $_[3]
    #my $stub = $_[4]
    #my dataKey = $_[5]

    my ( $newText, $blocks ) =
      VisDoc::StringUtils::replacePatternMatchWithStub( $_[1], $_[2], 0, $_[3],
        $_[4], $_[0]->{data}->getStubCounterRef() );

	return $newText unless keys %{$blocks};
	
    my $merged = $_[0]->{data}->mergeData( $_[5], $blocks );
    $_[0]->{data}->{ $_[5] } = $merged;

    return $newText;
}

=pod

_stubCode( $text ) -> $text

Calls _stubCodeBlocks.
Calls _stubCodeTags.

Returns the processed text.

=cut

sub _stubCode {

    #my $this = $_[0]
    #my $text = $_[1]

    my $newText;
    $newText = $_[0]->_stubCodeBlocks( $_[1] );
    $newText = $_[0]->_stubCodeTags($newText);

    return $newText;
}

=pod
 
_stubCodeBlocks( $text ) -> $text
 
Replaces <code>...</code> blocks by stubs.
Stores stubs in %data.

=cut

sub _stubCodeBlocks {

    #my $this = $_[0]
    #my $text = $_[1]

    return $_[0]->_stubTags(
        \$_[1],
        $VisDoc::StringUtils::PATTERN_CODE_BLOCK,
        $VisDoc::StringUtils::PATTERN_CODE_BLOCK_CONTENT_INDEX,
        $VisDoc::StringUtils::STUB_CODE_BLOCK,
        VisDoc::FileData::getDataKey($VisDoc::StringUtils::STUB_TAG_CODE)
    );
}

=pod

_stubCodeTags( $text ) -> $text
 
=cut

sub _stubCodeTags {

    #my $this = $_[0]
    #my $text = $_[1]

    return $_[0]->_stubTags(
        \$_[1],
        $VisDoc::StringUtils::PATTERN_TAG_CODE,
        $VisDoc::StringUtils::PATTERN_TAG_CODE_CONTENT_INDEX,
        $VisDoc::StringUtils::STUB_TAG_CODE,
        VisDoc::FileData::getDataKey($VisDoc::StringUtils::STUB_TAG_CODE)
    );
}

=pod

_stubLinkTags( $text ) -> $text

Replaces {@link...} tags with stubs.
Stores stubs in %data.

Returns the processed text.

=cut

sub _stubLinkTags {

    #my $this = $_[0]
    #my $text = $_[1]

    return $_[0]->_stubTags(
        \$_[1],
        $VisDoc::StringUtils::PATTERN_TAG_LINK,
        $VisDoc::StringUtils::PATTERN_TAG_LINK_CONTENT_INDEX,
        $VisDoc::StringUtils::STUB_INLINE_LINK,
        VisDoc::FileData::getDataKey($VisDoc::StringUtils::STUB_INLINE_LINK)
    );
}

=pod

_stubUrls( $text ) -> $text

Replaces http:// urls with stubs.
Stores stubs in %data.

Returns the processed text.

=cut

sub _stubUrls {

    #my $this = $_[0]
    #my $text = $_[1]

    return $_[0]->_stubTags(
        \$_[1],
        $VisDoc::StringUtils::PATTERN_URL,
        1,
        $VisDoc::StringUtils::STUB_INLINE_LINK,
        VisDoc::FileData::getDataKey($VisDoc::StringUtils::STUB_INLINE_LINK)
    );
}

=pod

_stubLiteralTags( $text ) -> $text

Replaces {@literal...} tags with stubs.
Stores stubs in %data.

Returns the processed text.

=cut

sub _stubLiteralTags {

    #my $this = $_[0]
    #my $text = $_[1]

    return $_[0]->_stubTags(
        \$_[1],
        $VisDoc::StringUtils::PATTERN_TAG_LITERAL,
        $VisDoc::StringUtils::PATTERN_TAG_LITERAL_CONTENT_INDEX,
        $VisDoc::StringUtils::STUB_TAG_LITERAL,
        VisDoc::FileData::getDataKey($VisDoc::StringUtils::STUB_TAG_LITERAL)
    );
}

=pod

_handleImageTags( $text )

Converts {@img image.jpg} tags to <img src="img/image.jpg" /> tags.

=cut

sub _handleImageTags {

    #my $this = $_[0]
    #my $text = $_[1]

	my $imgUrl = "../$VisDoc::Defaults::DESTINATION_IMG/";
	$_[1] =~ s/$VisDoc::StringUtils::PATTERN_TAG_IMG/<img src="$imgUrl$1" alt="$1" \/>/gx;	
}

=pod

stubArrays( $text, $pattern, $matchIndex ) -> $text
	  
=cut

sub stubArrays {
    my ( $this, $inText, $inPattern, $inMatchIndex ) = @_;

    #my $this = $_[0]
    #my $text = $_[1]

    return $inText if !$inText;
    my ( $newText, $blocks ) = VisDoc::StringUtils::replacePatternMatchWithStub(
        \$_[1], $inPattern, $inMatchIndex, $inMatchIndex,
        $VisDoc::StringUtils::VERBATIM_STUB_ARRAY,
        $_[0]->{data}->getStubCounterRef()
    );

    my $merged =
      $this->{data}
      ->mergeData( $VisDoc::StringUtils::VERBATIM_STUB_ARRAY, $blocks );
    $this->{data}->{'arrays'} = $merged;

    return $newText;
}

=pod

_stubJavadocComments( $text ) -> $text

=cut

sub _stubJavadocComments {

    #my $this = $_[0]
    #my $text = $_[1]

    my $newText = $_[0]->_stubRegularJavadocComments( $_[1] );
    $newText = $_[0]->_stubJavadocSideComments($newText);

    return $newText;
}

=pod

_stubRegularJavadocComments( $text ) -> $text

put /**...*/ in FileData and replace by stub strings

=cut

sub _stubRegularJavadocComments {

    #my $this = $_[0]
    #my $text = $_[1]

    my ( $newText, $blocks ) = $_[0]->_replaceJavadocCommentsByStubs( $_[1] );

    my $merged = $_[0]->{data}->mergeData( 'javadocComments', $blocks );
    $_[0]->{data}->{'javadocComments'} = $merged;


    return $newText;
}

=pod

_stubJavadocSideComments( $text) -> $text

put /**<...*/ in FileData and replace by stub strings

=cut

sub _stubJavadocSideComments {

    #my $this = $_[0]
    #my $text = $_[1]

    my ( $newText, $blocks ) =
      $_[0]->_replaceJavadocSideCommentsByStubs( $_[1] );

    my $merged = $_[0]->{data}->mergeData( 'javadocComments', $blocks );
    $_[0]->{data}->{'javadocComments'} = $merged;

    return $newText;
}

=pod

_stubQuotedStrings( $text) -> $text

put "..." and '...' in FileData and replace by stub strings

=cut

sub _stubQuotedStrings {

    #my $this = $_[0]
    #my $text = $_[1]

    my ( $newText, $blocks ) = $_[0]->_replaceQuotedStringsByStubs( $_[1] );

    my $merged = $_[0]->{data}->mergeData( 'quotedStrings', $blocks );
    $_[0]->{data}->{'quotedStrings'} = $merged;

    return $newText;
}

=pod

parseJavadoc( $javadocStub ) -> $javadocData

=cut

sub parseJavadoc {
    my ( $this, $inJavadocStub ) = @_;

    return undef if !$inJavadocStub;

    # regular javadoc comments
    my $javadocText = $this->{data}->{'javadocComments'}->{$inJavadocStub};

    my VisDoc::JavadocParser $javadocParser = VisDoc::JavadocParser->new();
    my $javadocData = $javadocParser->parse( $javadocText, $this->{data} );

    # DO NOT DELETE THE STUB AS THIS MAY BE USED BY OTHER MEMBERS

    return $javadocData;
}

=pod

Replace stubs by the original contents.

=cut

sub getContents {
    my ( $this, $inText ) = @_;

    return $this->{data}->getContents($inText);
}

=pod

replaceJavadocsByStubs( $text ) -> ($textWithPlaceholders, \%javadocs )

Replaces {@code ...} blocks by stubs.

=cut

sub _replaceJavadocCommentsByStubs {
    my ( $this, $inText ) = @_;

    return VisDoc::StringUtils::replacePatternMatchWithStub(
        \$inText,
        $VisDoc::StringUtils::PATTERN_JAVADOC_COMMENT,
        1,
        $VisDoc::StringUtils::PATTERN_JAVADOC_COMMENT_CONTENT_INDEX,
        $VisDoc::StringUtils::STUB_JAVADOC_COMMENT,
        $this->{data}->getStubCounterRef()
    );
}

=pod

_replaceJavadocSideCommentsByStubs( $text ) -> ($textWithPlaceholders, \%javadocs )

Replaces /**<...*/ blocks by stubs.

	javadocs has this structure:
	%javadocs = (
		int => string
	);

Replaces javadoc blocks with a numbered placeholder string.

=cut

sub _replaceJavadocSideCommentsByStubs {
    my ( $this, $inText ) = @_;

    return VisDoc::StringUtils::replacePatternMatchWithStub(
        \$inText,
        $VisDoc::StringUtils::PATTERN_JAVADOC_SIDE,
        0,
        $VisDoc::StringUtils::PATTERN_JAVADOC_SIDE_CONTENT_INDEX,
        $VisDoc::StringUtils::STUB_JAVADOC_SIDE,
        $this->{data}->getStubCounterRef()
    );
}

=pod

_replaceQuotedStringsByStubs( $text ) -> ($textWithPlaceholders, \%strings )

Replaces "..." and '...' blocks by stubs.

=cut

sub _replaceQuotedStringsByStubs {
    my ( $this, $inText ) = @_;

    use Regexp::Common qw( RE_quoted );
    my $quotedPattern = RE_quoted( -keep );

    return VisDoc::StringUtils::replacePatternMatchWithStub(
        \$inText, $quotedPattern, 1, 1,
        $VisDoc::StringUtils::VERBATIM_STUB_QUOTED_STRING,
        $this->{data}->getStubCounterRef()
    );
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
