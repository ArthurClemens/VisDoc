# See bottom of file for license and copyright information

package VisDoc::StringUtils;

use strict;
use warnings;

our $PATTERN_URL = '(?:[^\'\"]|^)\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))';

our $PATTERN_TAG_PACKAGE_CLASS_METHOD_LABEL = '
  ^
  (                          # i1
  (                          # i2
  ([[:alnum:]_\$\.]+)        # i3: package
  \.                         # dot
  )*      
  ([[:alnum:]_\$]+)          # i4: class
  )*
  \#?                        # hash char
  ([[:alnum:]_\$]+)*         # i5: member
  [[:space:]]*
  (\(.*?\))*                 # i6: params
  [[:space:]]*
  (.*?)                      # i7: label 
  $';

our $PATTERN_TAG_SENDS_WITH_COMMENT = '
  ^                       # start of string
  (.*?)                   # i1: any char
  [[:space:]]*            # any space
  (                       # i2: comment part
  \#                      # dash char (start of comment)
  [[:space:]]*            # any space
  (.*?)                   # i3: comment
  )*                      # /i2
  $                       # end of string
  ';

our $PATTERN_PACKAGE_CLASS = '
   (                      # i1: group package
   ([[:alnum:]_\$\.]+)    # i2: package
   \.                     # .
   )*                     # /i1
   ([[:alnum:]_\$]+)      # i3: class
';

our $PATTERN_PACKAGE_METHOD = '
    [[:alnum:]_\$]+
';

our $PATTERN_MULTILINE_COMMENT = '
   /\*			# /*
   [^\*]		# prevent matching javadoc comments
   .*?			# the contents, does not have to be preserved
   \*/			# */
   ';

our $PATTERN_EMPTY_MULTILINE_COMMENT = '/\*\*/';    # /**/
our $PATTERN_SINGLELINE_COMMENT      = '
   [[:space:]]*	# any preceding spaces
   //			# //
   .*			# rest of string
   ';

our $PATTERN_JAVADOC_COMMENT = '
   (?:^|[^/])     # no other characters in front except spaces
   (
   /\*\*		# /**
   [[:space:]]*		# any space
   (			# i1: contents
   [^</]	    # any char that is not < (does not match side comments) or / (skip /**/ comments)
   .*?			#
   )			# /i1
   [[:space:]]*	# any space
   \*/			# */
   )
   ';
our $PATTERN_JAVADOC_COMMENT_CONTENT_INDEX = 2;
our $STUB_JAVADOC_COMMENT                  = 'VISDOC_STUB_JAVADOC_COMMENT';

our $PATTERN_JAVADOC_STARS_AT_LEFT = '[[:space:]]*\*[[:space:]]*';

our $PATTERN_JAVADOC_SIDE = '
  /\*\*<			# /**<
  [[:space:]]*		# any space
  (.*?)				# i1: content
  [[:space:]]*		# any space
  \*/				# */
  ';
our $PATTERN_JAVADOC_SIDE_CONTENT_INDEX = 1;
our $STUB_JAVADOC_SIDE                  = 'VISDOC_STUB_JAVADOC_SIDE';

our $PATTERN_CODE_BLOCK = '
  <(?:code|pre)\s*.*?> 	# opening tag: either code or pre
  (?:\s*\n)*
  (.*?)                 # i1: code contents
  (?:\s*\n)*
  </(?:code|pre)>	    # closing tag
  ';
our $PATTERN_CODE_BLOCK_CONTENT_INDEX = 1;
our $STUB_CODE_BLOCK                  = 'VISDOC_STUB_CODE_BLOCK';

# code tags: {@code ...}
our $PATTERN_TAG_CODE = '
   {@code			# opening tag
   [[:space:]]*		# any space
   (.*?)			# i1: contents
   }				# close tag
   ';
our $PATTERN_TAG_CODE_CONTENT_INDEX = 1;
our $STUB_TAG_CODE                  = 'VISDOC_STUB_TAG_CODE';

# code tags: {@link ...}
our $PATTERN_TAG_LINK = '
   {@(?:linkplain|link)   # opening tag
   [[:space:]]*		      # any space
   (.*?)			      # i1: contents
   }				      # close tag
   ';
our $PATTERN_TAG_LINK_CONTENT_INDEX = 1;
our $STUB_INLINE_LINK               = 'VISDOC_STUB_INLINE_LINK';

# literal tags: {@literal ...}
our $PATTERN_TAG_LITERAL = '
   {@literal		# opening tag
   [[:space:]]*		# any space
   (.*?)			# i1: contents
   }				# close tag
   ';
our $PATTERN_TAG_LITERAL_CONTENT_INDEX = 1;
our $STUB_TAG_LITERAL                  = 'VISDOC_STUB_TAG_LITERAL';

# img tags: {@img ...}
our $PATTERN_TAG_IMG = '
   {@img		# opening tag
   [[:space:]]*		# any space
   (.*?)			# i1: contents
   }				# close tag
   [[:space:]]*		# any space
   ';
our $PATTERN_TAG_IMG_CONTENT_INDEX = 1;

# inheritDoc tags: {@inheritDoc}
our $PATTERN_TAG_INHERITDOC = '
   {@inheritDoc		# opening tag
   [[:space:]]*		# any space
   (.*?)			# i1: contents
   [[:space:]]*		# any space
   }				# close tag
   ';

#our $PATTERN_TAG_INHERITDOC_CONTENT_INDEX = 1;
our $STUB_TAG_INHERITDOC      = 'VISDOC_STUB_TAG_INHERITDOC';
our $STUB_TAG_INHERITDOC_LINK = 'VISDOC_STUB_TAG_INHERITDOC_LINK';

our $PATTERN_CDATA = '
  (					# i1: start of CDATA
  \<\!\[CDATA\[		# <![CDATA[
  )					#
  (.*?)				# i2: contents
  (					# i3: end of CDATA
  \]\]\>			# ]]>
  )					#
  ';
my $PLACEHOLDER_CDATA_START_TAG = 'PLACEHOLDER_CDATA_START_TAG';
my $PLACEHOLDER_CDATA_END_TAG   = 'PLACEHOLDER_CDATA_END_TAG';

our $VERBATIM_STUB_QUOTED_STRING    = 'VISDOC_STUB_QUOTED_STRING';
our $STRINGUTILS_STUB_QUOTED_STRING = 'VISDOC_STRINGUTILS_STUB_QUOTED_STRING';
our $VERBATIM_STUB_PROPERTY_OBJECT  = 'VISDOC_STUB_PROPERTY_OBJECT';
our $VERBATIM_STUB_ARRAY            = 'VISDOC_STUB_ARRAY';

our $PLACEHOLDER_LINEBREAK = 'VISDOC_PLACEHOLDER_LINEBREAK';
our $STUB_SPACE            = 'VISDOC_STUB_SPACE';

our $STUB_COLORIZE_CODE_STRING_START = 'VISDOC_STUB_COLORIZE_CODE_STRING_START';
our $STUB_COLORIZE_CODE_STRING_END   = 'VISDOC_STUB_COLORIZE_CODE_STRING_END';
our $STUB_COLORIZE_CODE_NUMBER_START = 'VISDOC_STUB_COLORIZE_CODE_NUMBER_START';
our $STUB_COLORIZE_CODE_NUMBER_END   = 'VISDOC_STUB_COLORIZE_CODE_NUMBER_END';
our $STUB_COLORIZE_CODE_COMMENT_START =
  'VISDOC_STUB_COLORIZE_CODE_COMMENT_START';
our $STUB_COLORIZE_CODE_COMMENT_END = 'VISDOC_STUB_COLORIZE_CODE_COMMENT_END';
our $STUB_COLORIZE_CODE_KEYWORD_START =
  'VISDOC_STUB_COLORIZE_CODE_KEYWORD_START';
our $STUB_COLORIZE_CODE_KEYWORD_END = 'VISDOC_STUB_COLORIZE_CODE_KEYWORD_END';
our $STUB_COLORIZE_CODE_IDENTIFIER_START =
  'VISDOC_STUB_COLORIZE_CODE_INDENTIFIER_START';
our $STUB_COLORIZE_CODE_IDENTIFIER_END =
  'VISDOC_STUB_COLORIZE_CODE_INDENTIFIER_END';
our $STUB_COLORIZE_CODE_PROPERTY_START =
  'VISDOC_STUB_COLORIZE_CODE_PROPERTY_START';
our $STUB_COLORIZE_CODE_PROPERTY_END = 'VISDOC_STUB_COLORIZE_CODE_PROPERTY_END';

=pod
our $JAVADOC_FIELD_NAMES_INLINE = {
	'code' => 1,
	'img' => 1,
	'inheritDoc' => 1,
	'link' => 1,
	'linkplain' => 1,
	'literal' => 1,
};
=cut

sub new {
    my ( $class, $name ) = @_;
}

=pod

=cut

sub stripAllComments {

    #my $text = $_[0]

    stripEmptyMultilineComments( $_[0] );
    stripMultilineComments( $_[0] );
    stripSingleLineComments( $_[0] );
}

=pod

=cut

sub stripToPrepareReadingLanguageId {

    #my $text = $_[0]

    stripEmptyMultilineComments( $_[0] );
    stripMultilineComments( $_[0] );
    stripSingleLineComments( $_[0] );
    stripJavadocComments( $_[0] );
    replaceCDATATags( $_[0] );
    reduceNewlinesToSingle( $_[0] );

    use Regexp::Common qw( RE_quoted );
    my $quotedPattern = RE_quoted( -keep );
    $_[0] =~ s/$quotedPattern/REMOVED_STRING/g;
}

=pod

Replaces \r by \n

=cut

sub replaceBackslashR {

    #my $text = $_[0]

    $_[0] =~ s/\r/\n/g;
}

=pod

Replaces tabs by spaces.

=cut

sub replaceTabsBySpaces {

    #my $text = $_[0]

    $_[0] =~ s/\t+/ /g;
}

=pod

Replaces multi spaces by single spaces.

=cut

sub reduceSpacesToSingle {

    #my $text = $_[0]

    $_[0] =~ s/\s+/ /g;
}

=pod

Replaces triple (and more) \n\n\n by double \n\n

=cut

sub reduceNewlinesToDouble {

    #my $text = $_[0]

    $_[0] =~ s/(\n\s*){2,}/$1$1/gosx;
}

=pod

Replaces triple (and more) \n\n\n by single \n

=cut

sub reduceNewlinesToSingle {

    #my $text = $_[0]

    $_[0] =~ s/(\n\s*)/\n/gosx;
}

=pod

Removes /**ABC*/ comments.
stripJavadocComments($text) -> $text

=cut

sub stripJavadocComments {

    #my $text = $_[0]

    $_[0] =~ s/$PATTERN_JAVADOC_COMMENT//gosx;
    $_[0] =~ s/$PATTERN_JAVADOC_SIDE//gosx;
}

=pod

Removes /*ABC*/ comments.
stripMultilineComments($text) -> $text

=cut

=pod should be:

    s{
       /\*         ##  Start of /* ... */ comment
       [^*]*\*+    ##  Non-* followed by 1-or-more *'s
       (
         [^/*][^*]*\*+
       )*          ##  0-or-more things which don't start with /
                   ##    but do end with '*'
       /           ##  End of /* ... */ comment

     |         ##     OR  various things which aren't comments:

       (
         "           ##  Start of " ... " string
         (
           \\.           ##  Escaped char
         |               ##    OR
           [^"\\]        ##  Non "\
         )*
         "           ##  End of " ... " string

       |         ##     OR

         '           ##  Start of ' ... ' string
         (
           \\.           ##  Escaped char
         |               ##    OR
           [^'\\]        ##  Non '\
         )*
         '           ##  End of ' ... ' string

       |         ##     OR

         .           ##  Anything other char
         [^/"'\\]*   ##  Chars which doesn't start a comment, string or escape
       )
     }{defined $2 ? $2 : ""}gxse;

=cut

sub stripMultilineComments {

    #my $text = $_[0]

    $_[0] =~ s/$PATTERN_MULTILINE_COMMENT//gosx;
}

=pod

Removes /**/ comments.
stripEmptyMultilineComments($text) -> $text

=cut

sub stripEmptyMultilineComments {

    #my $text = $_[0]

    $_[0] =~ s/$PATTERN_EMPTY_MULTILINE_COMMENT//gosx;
}

=pod

stripSingleLineComments( $text ) -> $text

Removes // comments.

=cut

sub stripSingleLineComments {

    #my $text = $_[0]

    $_[0] =~ s/$PATTERN_SINGLELINE_COMMENT//gox;
}

=pod

Removes strings inside <...> tags

=cut

sub stripHtml {

    #my $text = $_[0]

    $_[0] =~ s/\<[^\>]+\>//go;

}

=pod

=cut

sub convertHtmlEntities {

    #my $text = $_[0]

    # encode all non-printable 7-bit chars (< \x1f),
    # except \n (\xa) and \r (\xd)
    # encode HTML special characters '>', '<', '&', ''' and '"'.
    # encode TML special characters '%', '|', '[', ']', '@', '_',
    # '*', and '='
    #$_[0] =~
    #  s/([[\x01-\x09\x0b\x0c\x0e-\x1f"&'*<=>[])/'&#'.ord($1).';'/ge;

    #$_[0] =~ s/\</&lt;/go;
    #$_[0] =~ s/\>/&gt;/go;

    eval "use HTML::Entities";
    if ($@) {
        print STDOUT $@;
        die;
    }
    encode_entities( $_[0] );
}

=pod

replaceNewlinesBySpaces( $text ) -> $text

Replaces \n newlines by spaces.

=cut

sub replaceNewlinesBySpaces {

    #my $text = $_[0]

    $_[0] =~ s/\n+/ /g;
}

=pod

trimSpaces( $text )

Removes spaces from both sides of the text.

=cut

sub trimSpaces {

    #my $text = $_[0]

    $_[0] =~ s/^[[:space:]]+//s;    # trim at start
    $_[0] =~ s/[[:space:]]+$//s;    # trim at end
}

=pod

Removes the BOM character from unicode text.

=cut

sub trimBOM {

    #my $text = $_[0]

    $_[0] =~ s/^\xEF\xBB\xBF//;
}

=pod

deletePathExtension ( $text )

=cut

sub deletePathExtension {

    #my $text = $_[0]

    # remove last / unless this is root
    $_[0] =~ s/^(.*?)\/$/$1/ unless $_[0] eq '/';

    my $pattern = qr/^(.*?)\.\w*$/;
    if ( $_[0] =~ /$pattern/ ) {
        $_[0] = $1 if $1;
    }
}

=pod

commaSeparatedListFromCommaSeparatedString( $text ) -> @list

Creates a comma-separated array. Preserves commas inside quotes.

=cut

sub commaSeparatedListFromCommaSeparatedString {

    #my $text = $_[0]

    my $counter = 0;
    use Regexp::Common qw( RE_quoted );
    my $quotedPattern = RE_quoted( -keep );

    my ( $textWithPlaceholders, $store ) =
      replacePatternMatchWithStub( \$_[0], $quotedPattern, 1, 1,
        $STRINGUTILS_STUB_QUOTED_STRING, \$counter );

    return ( $_[0] ) if !$textWithPlaceholders;
    my @list = split( /,\s*/, $textWithPlaceholders );

    # retrieve original store
    my $pattern = getStubKeyPattern($STRINGUTILS_STUB_QUOTED_STRING);

    foreach my $item (@list) {
        while ( $item =~ m/($pattern)/gxs ) {
            my $key   = $1;
            my $value = $store->{$key};
            $item =~ s/$key/$value/ if $value;
        }
    }
    return @list;
}

=pod

commaSeparatedListFromSpaceSeparatedString( $text ) -> @list

Creates a comma-separated array. Preserves commas inside quotes.

=cut

sub commaSeparatedListFromSpaceSeparatedString {

    #my $text = $_[0]
    return undef if !$_[0];

    my $counter = 0;
    use Regexp::Common qw( RE_quoted );
    my $quotedPattern = RE_quoted( -keep );

    my ( $textWithPlaceholders, $store ) =
      replacePatternMatchWithStub( \$_[0], $quotedPattern, 1, 1,
        $VERBATIM_STUB_QUOTED_STRING, \$counter );

    my @list = split( /\s+/, $textWithPlaceholders );

    # retrieve original store
    my $pattern = getStubKeyPattern($VERBATIM_STUB_QUOTED_STRING);

    foreach my $item (@list) {
        if ( $item =~ m/($pattern)/ ) {
            my $key   = $1;
            my $value = $store->{$key};
            $item =~ s/$key/$value/ if $value;
        }
    }
    return @list;
}

=pod

Replaces <![CDATA[...]]> tags by $PLACEHOLDER_CDATA_START_TAG...$PLACEHOLDER_CDATA_END_TAG.
Does not store contents in a hash, merely replaced tags that may disturb parsing.

=cut

sub replaceCDATATags {

    #my $text = $_[0]

    $_[0] =~
s/$PATTERN_CDATA/$PLACEHOLDER_CDATA_START_TAG$2$PLACEHOLDER_CDATA_END_TAG/gosx;
}

sub restoreCDATATags {

    #my $text = $_[0]

    $_[0] =~ s/$PLACEHOLDER_CDATA_START_TAG/<![CDATA[/gosx;
    $_[0] =~ s/$PLACEHOLDER_CDATA_END_TAG/]]>/gosx;
}

=pod

removeStarsInJavadoc ( $javadocString )

Removes stars at the start of each line.

=cut

sub removeStarsInJavadoc {

    #my $text = $_[0]

    return if !$_[0];

    $_[0] =~ s/$PATTERN_JAVADOC_STARS_AT_LEFT/\n/gosx;
}

=pod

getLastPathComponent( $path ) -> $text

Class method that returns the last path component. For example:

	root/mypath/myfile.as -> myfile
	myfile.java -> myfile
	
=cut

sub getLastPathComponent {
    my ( $inPath ) = @_;

    use File::Basename();
    my @suffixlist = qw(as java);
    my $name = File::Basename::fileparse( $inPath, @suffixlist );
    $name =~ s/^(.*?)\.$/$1/;    # strip remaining dot (why is it there?)
    return $name;
}

=pod

stripCommentsFromRegex($pattern) -> $pattern

Removes all spaces and comments from a regular expression.

Protects excaped # chars:

\#

will become

#

=cut

sub stripCommentsFromRegex {
    my ($inRegex) = @_;

    my $cleanRegex = $inRegex;

    # protect escaped # chars
    $cleanRegex =~ s/(\\#)/%VISDOC_ESCAPED_HASH%/go;
    $cleanRegex =~ s/\s*(.*?)\s*(#.*?)*(\r|\n|$)/$1/go;
    $cleanRegex =~ s/%VISDOC_ESCAPED_HASH%/#/go;
    return $cleanRegex;
}

=pod

listFromKeywordWithCommaDelimitedString($text, $keyword, $wordregex) -> @list

For example, from the string:

	implements Paintable, java.io.Serializable, Collection<String> extends Hello

this list will be created:

	(Paintable, java.io.Serializable, Collection<String>)
	
=cut

sub listFromKeywordWithCommaDelimitedString {
    my ( $inText, $inKeyword ) = @_;

    my @matches = ();
    ( my $text = $inText ) =~
      s/\s*,\s*/,/go;    # remove all spaces after the commas
    my $regex = '
	  ' . $inKeyword . '
	  [[:space:]]+	# one or more spaces
	  ([^\s$]+)	    # any char that is not a space or the end
	  ';
    if ( $text =~ m/$regex/sxi ) {
        @matches = split( /,/, $1 );
    }
    return @matches;
}

=pod

StaticMethod replacePatternMatchWithStub( \$text, $pattern, $matchIndex, $replaceMatchIndex, $stub, \$counter ) -> ($textWithPlaceholders, \%hash)

Helper function that replaces a block of text by a placeholder stub (numbered so it can be found back).
Returns a tuple of replaced text and storage hash.

Example 1:

In text 'aaa111ccc' replace '111' by '_NUMBERS_':

replacePatternMatchWithStub(
	\'aaa111ccc',
	'([0-9]+)',
	1,
	1, # replace entire match
	_NUMBERS_,
	\0
);

Example 2:

In text 'a = [1,2,3]' replace '[1,2,3]' by '_ARRAY_', but leave ' = ' intact:

replacePatternMatchWithStub(
	\'a = [1,2,3]',
	'\s*\=\s*(\[.*?\])',
	1, # only match the group
	1, # replace the group
	_ARRAY_,
	\0
);


=cut

sub replacePatternMatchWithStub {
    my ( $inText, $inPattern, $inMatchIndex, $inReplaceMatchIndex, $inStub,
        $inCounterRef )
      = @_;

    my $text = $$inText;
    return ( undef, undef ) if !$text;

    my %storage = ();

    while ( $text =~ m/$inPattern/gxs ) {
        storeStubReference(
            \$text,                   $-[$inMatchIndex],
            $+[$inMatchIndex],        $-[$inReplaceMatchIndex],
            $+[$inReplaceMatchIndex], \%storage,
            $inStub,                  ++$$inCounterRef
        );
    }

    return ( $text, \%storage );
}

=pod

StaticMethod storeStubReference(\$text, $startPos, $endPos, \%collection, $stubName, $count) -> $stubString

Helper function; stores $text in hash reference $collection, with key $count.

%collection = (
	$count => $text
);

$text: complete text to store a fragment of
$startMatch: start position of part to store
$endMatch: end position of part to store
$startReplace:
$endReplace:
$collection: reference to hash to store original text fragment in
$stubName: name of stub
$count: stub counter to make stub key unique (combination of stubName + counter)

Returns the numbered stub string.

=cut

sub storeStubReference {
    my ( $inText, $inStartMatch, $inEndMatch, $inStartReplace, $inEndReplace,
        $inCollection, $inStubName, $inCount )
      = @_;

    my $stub = getStubKey( $inStubName, $inCount );

    my $text = $$inText;

    # lift out the entire match
    my $matchStr =
      substr( $$inText, $inStartMatch, $inEndMatch - $inStartMatch, $stub );

    # replace match in text with stub
    my $replaceStr =
      substr( $text, $inStartReplace, $inEndReplace - $inStartReplace );

    # store in hash reference
    $inCollection->{$stub} = $replaceStr;

    return $inText;
}

=pod

Creates a stub key according to name template %name_number%.

=cut

sub getStubKey {
    my ( $inName, $inNumber ) = @_;

    return '%' . $inName . '_' . $inNumber . '%';
}

=pod

Creates a stub regex pattern according to name template {name{number}}.

Pattern:
%
($tagName)		# i1: name of tag
_
([0-9]+)		# i2: number
%

=cut

sub getStubKeyPattern {
    my ($inName) = @_;

    return '%' . $inName . '_' . "([0-9]+)" . '%';
}

=pod

Creates a combined stub regex pattern according to name template {name{number}}.

Pattern:
%
($tagName1|$tagName2|$tagNamen)	# i1: name2 of tag
_
([0-9]+)						# i2: number
%

=cut

sub getStubKeyPatternForTagNames {
    my (@inNames) = @_;

    my $names = '(' . join( "|", @inNames ) . ')';
    return '%' . $names . '_' . "([0-9]+)" . '%';
}

=pod

StaticMethod handleStarsInCodeText ( $text, $doPreserveLineBreaks ) 

=cut

sub handleStarsInCodeText {

    #my $text = $_[0]
    #my $doPreserveLineBreaks = $_[1]

    # remove very first star and tab, to prevent putting a newline there
    $_[0] =~ s/^(\t|\s)*\*(\t|\s)*//gs;

    if ( $_[1] ) {

        # first preserve empty lines
        $_[0] =~ s/(\n)(\s*?\*\s{0,1})(\n)/$1$PLACEHOLDER_LINEBREAK$3/gs;
    }
    else {

        # remove empty lines
        $_[0] =~ s/(\n)(\s*?\*\s{0,1})\n/$1/gs;
    }

    # remove stars at beginning of lines
    $_[0] =~ s/(\n)(\s*\*\s{0,1})/$1/gs;

    # cleanup
    $_[0] =~ s/$PLACEHOLDER_LINEBREAK//gs;
}

=pod

TODO

=cut

sub preserveLinebreaks {
    #my $text = $_[0]
        
	# first preserve empty lines
	$_[0] =~ s/(\n)(\s*?\*\s{0,1})(\n)/$1$PLACEHOLDER_LINEBREAK$3/gs;

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
