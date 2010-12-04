use strict;
use warnings;
use diagnostics;

package StringUtilsTests;
use base qw(Test::Unit::TestCase);

use VisDoc::StringUtils;
use VisDoc::ClassData;

my $debug = 0;

sub new {
    my $self = shift()->SUPER::new(@_);

    # your state for fixture here
    return $self;
}

=pod

=cut

sub test_stripSingleLineComments_simple {
    my ($this) = @_;

    my $text = 'public static const NONE:uint = 0; // not here';
    VisDoc::StringUtils::stripSingleLineComments($text);
    my $result   = $text;
    my $expected = 'public static const NONE:uint = 0;';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripSingleLineComments {
    my ($this) = @_;

    my $text = '//public class TraverseOptions {
public class TraverseArrayOptions {

	public static const NONE:uint = 0; // not here

}';
    VisDoc::StringUtils::stripSingleLineComments($text);
    my $result   = $text;
    my $expected = 'public class TraverseArrayOptions {

	public static const NONE:uint = 0;

}';

    $result   =~ s/^\s*(.*)\s*$/$1/gos;
    $expected =~ s/^\s*(.*)\s*$/$1/gos;
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripSingleLineComments_empty {
    my ($this) = @_;

    my $text = '';
    VisDoc::StringUtils::stripSingleLineComments($text);
    my $result   = $text;
    my $expected = '';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripEmptyMultilineComments {
    my ($this) = @_;

    my $text = 'abc/**/def';
    VisDoc::StringUtils::stripEmptyMultilineComments($text);
    my $result   = $text;
    my $expected = 'abcdef';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripEmptyMultilineComments_empty {
    my ($this) = @_;

    my $text = '';
    VisDoc::StringUtils::stripEmptyMultilineComments($text);
    my $result   = $text;
    my $expected = '';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripMultilineComments {
    my ($this) = @_;

    my $text = '/*
Copyright 2007 by the authors of asaplibrary, http://asaplibrary.org
Copyright 2005-2007 by the authors of asapframework, http://asapframework.org

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

/*
this is not
class TraverseArrayOptions {
*/
package org.asaplibrary.data.array /*ehm*/{

	/**
	Array traverse options used by TraverseArrayEnumerator. The state options use bitwise operators, see ButtonStates for an example.
	*/
	public class TraverseArrayOptions {
	
		public static const NONE:uint = 0; /**< The enumerator does nothing. */
		public static const LOOP:uint = 1; /**< The enumerator loops past the last item. */
		
	}
}
';
    VisDoc::StringUtils::stripMultilineComments($text);
    my $result   = $text;
    my $expected = 'package org.asaplibrary.data.array {

	/**
	Array traverse options used by TraverseArrayEnumerator. The state options use bitwise operators, see ButtonStates for an example.
	*/
	public class TraverseArrayOptions {
	
		public static const NONE:uint = 0; /**< The enumerator does nothing. */
		public static const LOOP:uint = 1; /**< The enumerator loops past the last item. */
		
	}
}
';

    $result   =~ s/^\s*(.*)\s*$/$1/gos;
    $expected =~ s/^\s*(.*)\s*$/$1/gos;
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripMultilineComments_empty {
    my ($this) = @_;

    my $text = '';
    VisDoc::StringUtils::stripMultilineComments($text);
    my $result   = $text;
    my $expected = '';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripAllComments {
    my ($this) = @_;

    my $text = '/*
Copyright 2007 by the authors of asaplibrary, http://asaplibrary.org
Copyright 2005-2007 by the authors of asapframework, http://asapframework.org

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

/*
this is not
class TraverseArrayOptions {
// COMMENT
*/
package org.asaplibrary.data.array /*ehm*/{

	/*
	Array traverse options used by TraverseArrayEnumerator. The state options use bitwise operators, see ButtonStates for an example.
	*/
	// COMMENT
	public class TraverseArrayOptions {

		public static const NONE:uint = 0; /**< The enumerator does nothing. */
		public static const LOOP:uint = 1; /**< The enumerator loops past the last item. */

	}
}';
    VisDoc::StringUtils::stripAllComments($text);

    my $result   = $text;
    my $expected = 'package org.asaplibrary.data.array {
	public class TraverseArrayOptions {

		public static const NONE:uint = 0; /**< The enumerator does nothing. */
		public static const LOOP:uint = 1; /**< The enumerator loops past the last item. */

	}
}';

    $result   =~ s/^\s*(.*)\s*$/$1/gos;
    $expected =~ s/^\s*(.*)\s*$/$1/gos;
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripAllComments_empty {
    my ($this) = @_;

    my $text = '';
    VisDoc::StringUtils::stripAllComments($text);
    my $result   = $text;
    my $expected = '';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripJavadocComments {
    my ($this) = @_;

    my $text = 'BEFORE
/**
* ABC
*/
AFTER';
    VisDoc::StringUtils::stripJavadocComments($text);
    my $result   = $text;
    my $expected = 'BEFORE
AFTER';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_replaceNewlinesBySpaces {
    my ($this) = @_;

    my $text = 'a
b
c
d';

    VisDoc::StringUtils::replaceNewlinesBySpaces($text);
    my $result   = $text;
    my $expected = 'a b c d';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripHtml {
    my ($this) = @_;

    my $text = '<code><br />text</code>';
    VisDoc::StringUtils::stripHtml($text);
    my $result   = $text;
    my $expected = 'text';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripJavadocComments_empty {
    my ($this) = @_;

    my $text = '';
    VisDoc::StringUtils::stripJavadocComments($text);
    my $result   = $text;
    my $expected = '';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

sub test_stripToPrepareReadingLanguageId {
    my ($this) = @_;

    my $text = '/**
* FlickrBlogs
* class com.zuardi.flickr.FlickrBlogs
{

* use "class com.zuardi.flickr.FlickrBlogs {"
*/;
class com.zuardi.flickr.FlickrBlogs
{
	
	/**
	Some comment.
	*/
	function FlickrBlogs()
	{
		var pets:Array = [new Cat(), new Dog()]; /**< class com.zuardi.flickr.FlickrBlogs { */
		for each (var pet:* in pets)
		{
			var example:String = "class com.zuardi.flickr.FlickrBlogs {";
		}
	}
};
';
    my $result = $text;
    VisDoc::StringUtils::stripToPrepareReadingLanguageId($result);
    my $expected = ';
class com.zuardi.flickr.FlickrBlogs
{
function FlickrBlogs()
{
var pets:Array = [new Cat(), new Dog()]; 
for each (var pet:* in pets)
{
var example:String = REMOVED_STRING;
}
}
};
';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_trimSpaces {
    my ($this) = @_;

    my $text = '
"abc"
def ghi   ';
    my $result = $text;
    VisDoc::StringUtils::trimSpaces($result);
    my $expected = '"abc"
def ghi';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_deletePathExtension {
    my ($this) = @_;

    {

        # '/tmp/scratch.tiff'
        my $text   = '/tmp/scratch.tiff';
        my $result = $text;
        VisDoc::StringUtils::deletePathExtension($result);
        my $expected = '/tmp/scratch';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # '/tmp/'
        my $text   = '/tmp/';
        my $result = $text;
        VisDoc::StringUtils::deletePathExtension($result);
        my $expected = '/tmp';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # 'scratch.bundle/'
        my $text   = 'scratch.bundle/';
        my $result = $text;
        VisDoc::StringUtils::deletePathExtension($result);
        my $expected = 'scratch';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # 'scratch..tiff'
        my $text   = 'scratch..tiff';
        my $result = $text;
        VisDoc::StringUtils::deletePathExtension($result);
        my $expected = 'scratch.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # '.tiff'
        my $text   = '.tiff';
        my $result = $text;
        VisDoc::StringUtils::deletePathExtension($result);
        my $expected = '.tiff';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # '/'
        my $text   = '/';
        my $result = $text;
        VisDoc::StringUtils::deletePathExtension($result);
        my $expected = '/';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_commaSeparatedListFromCommaSeparatedString {
    my ($this) = @_;

    my $text =
      'abc,def, ghi, aaa"ABC,DEF"bbb,  aaa\'ABC,DEF\'bbb, inKey:String = ",."';
    my @list =
      VisDoc::StringUtils::commaSeparatedListFromCommaSeparatedString($text);
    {

        # item 1
        my $result   = $list[0];
        my $expected = 'abc';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # item 2
        my $result   = $list[1];
        my $expected = 'def';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # item 3
        my $result   = $list[2];
        my $expected = 'ghi';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # item 4
        my $result   = $list[3];
        my $expected = 'aaa"ABC,DEF"bbb';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # item 5
        my $result   = $list[4];
        my $expected = 'aaa\'ABC,DEF\'bbb';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # item 6
        my $result   = $list[5];
        my $expected = 'inKey:String = ",."';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_commaSeparatedListFromSpaceSeparatedString {
    my ($this) = @_;

    my $text = 'a  b  c  d  "A B C" e';
    my @list =
      VisDoc::StringUtils::commaSeparatedListFromSpaceSeparatedString($text);
    {

        # item 5
        my $result   = $list[4];
        my $expected = '"A B C"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # item 6
        my $result   = $list[5];
        my $expected = 'e';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_replaceCDATATags {
    my ($this) = @_;

    my $text   = 'aaaaaaaaa<![CDATA[bbb]]>ccccccccccc';
    my $result = $text;
    VisDoc::StringUtils::replaceCDATATags($result);
    my $expected =
'aaaaaaaaaPLACEHOLDER_CDATA_START_TAGbbbPLACEHOLDER_CDATA_END_TAGccccccccccc';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_restoreCDATATags {
    my ($this) = @_;

    my $text =
'aaaPLACEHOLDER_CDATA_START_TAGCDATA CONTENTSPLACEHOLDER_CDATA_END_TAGbbb';
    my $result = $text;
    VisDoc::StringUtils::restoreCDATATags($result);
    my $expected = 'aaa<![CDATA[CDATA CONTENTS]]>bbb';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_removeStarsInJavadoc {
    my ($this) = @_;

    my $text = '* About speaking pets.
	* Usage:
	* <code>
	* new SpeakingPets();
	* </code>
	* or
	* {@code new SpeakingPets();}';
    my $result = $text;
    VisDoc::StringUtils::removeStarsInJavadoc($result);
    my $expected = '
About speaking pets.
Usage:
<code>
new SpeakingPets();
</code>
or
{@code new SpeakingPets();}';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_reduceNewlinesToDouble {
    my ($this) = @_;

    my $text = 'aaa
	
	
	
	
	
	
bbb';
    my $result = $text;
    VisDoc::StringUtils::reduceNewlinesToDouble($result);
    my $expected = 'aaa

bbb';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_reduceNewlinesToSingle {
    my ($this) = @_;

    my $text = 'aaa






bbb';
    my $result = $text;
    VisDoc::StringUtils::reduceNewlinesToSingle($result);
    my $expected = 'aaa
bbb';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

sub test_getLastPathComponent_1 {
    my ($this) = @_;

    my $path     = 'com/visiblearea/visdoc/StringUtils.as';
    my $result   = VisDoc::StringUtils::getLastPathComponent($path);
    my $expected = 'StringUtils';
    print("RES=$result.\n")     if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

sub test_getLastPathComponent_2 {
    my ($this) = @_;

    my $path     = 'StringUtils.as';
    my $result   = VisDoc::StringUtils::getLastPathComponent($path);
    my $expected = 'StringUtils';
    print("RES=$result.\n")     if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

sub test_getLastPathComponent_3 {
    my ($this) = @_;

    my $path     = 'StringUtils';
    my $result   = VisDoc::StringUtils::getLastPathComponent($path);
    my $expected = 'StringUtils';
    print("RES=$result.\n")     if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

sub test_getLastPathComponent_4 {
    my ($this) = @_;

    my $path =
'fictitious.as';
    my $result   = VisDoc::StringUtils::getLastPathComponent($path);
    my $expected = 'fictitious';
    print("RES=$result.\n")     if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}
=cut

=pod

=cut

sub test_stripCommentsFromRegex {
    my ($this) = @_;
    my $pattern = '
  (									# class access grouped at index 1
  \b(public|static|private|final|dynamic|intrinsic|internal|protected)*\b	# access
  [[:space:]]*						# any space
  (\\bclass\\b|\\binterface\\b)+	# "class" or "interface"
  )									#
  [[:space:]]*						# any space
  [[:alnum:]_\$.]+					# class name
  [[:space:]]*						# any space
  (\bextends\b|\bimplements\b)*		# "extends" or "implements"
  [[:space:]]*						# any space
  [[:alnum:][:punct:]]*				# extended class or implemented interface
  [[:space:]]*						# any space
  (\bextends\b|\bimplements\b)*		# "extends" or "implements"
  [[:space:]]*						# any space
  [[:alnum:][:punct:]]*				# extended class or implemented interface
  [[:space:]]*						# any space
  {									# opening brace
  ';
    my $result = VisDoc::StringUtils::stripCommentsFromRegex($pattern);
    my $expected =
'(\b(public|static|private|final|dynamic|intrinsic|internal|protected)*\b[[:space:]]*(\bclass\b|\binterface\b)+)[[:space:]]*[[:alnum:]_\$.]+[[:space:]]*(\bextends\b|\bimplements\b)*[[:space:]]*[[:alnum:][:punct:]]*[[:space:]]*(\bextends\b|\bimplements\b)*[[:space:]]*[[:alnum:][:punct:]]*[[:space:]]*{';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stripCommentsFromRegex_escape_hash {
    my ($this) = @_;

    my $pattern = '
  ^
  ((([[:alnum:]_\$\.]+)\.)*
  ([[:alnum:]_\$]+))*
  \#?([[:alnum:]_\$]+)*
  [[:space:]]*
  (\(.*?\))*
  [[:space:]]*
  (.*?)
  $';

    my $result = VisDoc::StringUtils::stripCommentsFromRegex($pattern);
    my $expected =
'^((([[:alnum:]_\$\.]+)\.)*([[:alnum:]_\$]+))*#?([[:alnum:]_\$]+)*[[:space:]]*(\(.*?\))*[[:space:]]*(.*?)$';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_listFromKeywordWithCommaDelimitedString {
    my ($this) = @_;

    my $text =
'extends Hello implements Paintable, java.io.Serializable, Collection<String>';
    my @list =
      VisDoc::StringUtils::listFromKeywordWithCommaDelimitedString( $text,
        'implements' );
    {

        # item 1
        my $result   = $list[0];
        my $expected = 'Paintable';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # item 2
        my $result   = $list[1];
        my $expected = 'java.io.Serializable';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # item 3
        my $result   = $list[2];
        my $expected = 'Collection<String>';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_handleStarsInCodeText_preserveLineBreaks {
    my ($this) = @_;

    my $text = '	* new SpeakingPets();
	* 
	* ABC';

    VisDoc::StringUtils::handleStarsInCodeText( $text, 1 );
    my $result   = $text;
    my $expected = 'new SpeakingPets();

ABC';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_handleStarsInCodeText_not_preserveLineBreaks {
    my ($this) = @_;

    my $text = '	* new SpeakingPets();
	* 
	* ABC * DEF';

    VisDoc::StringUtils::handleStarsInCodeText($text);
    my $result   = $text;
    my $expected = 'new SpeakingPets();
ABC * DEF';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_replacePatternMatchWithStub_1 {
    my ($this) = @_;

    my $text    = 'a = [1,2,3]';
    my $pattern = '\s*\=\s*(\[.*?\])';
    my $stub    = 'STUB';
    my $counter = 0;
    my ( $result, $storage ) =
      VisDoc::StringUtils::replacePatternMatchWithStub( \$text, $pattern, 1, 0,
        $stub, \$counter );

    my $expected = 'a = %STUB_1%';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_replacePatternMatchWithStub_2 {
    my ($this) = @_;

    my $text    = '= AB';
    my $stub    = 'STUB';
    my $pattern = '\=\s*(A)';
    my $counter = 0;
    my ( $newText, $storage ) =
      VisDoc::StringUtils::replacePatternMatchWithStub( \$text, $pattern, 1, 1,
        $stub, \$counter );

    {

        # test text
        my $result   = $newText;
        my $expected = '= %STUB_1%B';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_replacePatternMatchWithStub_3 {
    my ($this) = @_;

    my $text    = '/* comment */ /** hello comment */ ;';
    my $stub    = $VisDoc::StringUtils::STUB_JAVADOC_COMMENT;
    my $pattern = "$VisDoc::StringUtils::PATTERN_JAVADOC_COMMENT";

    my $counter = 0;
    my ( $newText, $storage ) =
      VisDoc::StringUtils::replacePatternMatchWithStub( \$text, $pattern, 0, 1,
        $stub, \$counter );

    {

        # test text
        my $result   = $newText;
        my $expected = '/* comment */%VISDOC_STUB_JAVADOC_COMMENT_1% ;';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

1;
