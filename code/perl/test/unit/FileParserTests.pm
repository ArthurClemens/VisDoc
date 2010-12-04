use strict;
use warnings;
use diagnostics;

package FileParserTests;
use base qw(Test::Unit::TestCase);

use VisDoc;
use VisDoc::StringUtils;
use VisDoc::FileParser;
use VisDoc::ParserBase;
use VisDoc::ParserAS2;
use VisDoc::ParserAS3;
use VisDoc::ParserJava;

my $debug = 0;

sub new {
    my $self = shift()->SUPER::new(@_);

    return $self;
}

sub set_up {
    my ($this) = @_;

    VisDoc::FileData::initLinkDataRefs();
}

=pod

=cut

sub test_getDataKey {
    my ($this) = @_;

    my $result =
      VisDoc::FileData::getDataKey($VisDoc::StringUtils::STUB_CODE_BLOCK);
    my $expected = 'codeBlocks';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_getParserForLanguage_as2 {
    my ($this) = @_;

    my $tmpFileParser = VisDoc::FileParser->new();
    my $parser        = $tmpFileParser->getParserForLanguage('as2');
    $this->assert_not_null($parser);
}

sub test_getParserForLanguage_as3 {
    my ($this) = @_;

    my $tmpFileParser = VisDoc::FileParser->new();
    my $parser        = $tmpFileParser->getParserForLanguage('as3');
    $this->assert_not_null($parser);
}

sub test_getParserForLanguage_java {
    my ($this) = @_;

    my $tmpFileParser = VisDoc::FileParser->new();
    my $parser        = $tmpFileParser->getParserForLanguage('java');
    $this->assert_not_null($parser);
}

=pod

Tests getData object.

=cut

sub test_getFileData {
    my ($this)    = @_;
    my $parser    = VisDoc::FileParser->new();
    my $parseData = $parser;
    $$parseData{language} = 'java';
    my $result   = $$parseData{language};
    my $expected = 'java';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_getLanguageId_java {
    my ($this) = @_;

    my $result   = VisDoc::FileParser::getLanguageId('mypath/myfile.java');
    my $expected = 'java';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_getLanguageId_as3 {
    my ($this) = @_;

    my $here   = Cwd::abs_path . '/testfiles';
    my $path   = "$here/testlanguage_as3.as";
    my $text   = VisDoc::readFile($path);
    my $result = VisDoc::FileParser::getLanguageId( 'mypath/myfile.as', $text );
    my $expected = 'as3';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_getLanguageId_as2 {
    my ($this) = @_;

    my $here   = Cwd::abs_path . '/testfiles';
    my $path   = "$here/testlanguage_as2.as";
    my $text   = VisDoc::readFile($path);
    my $result = VisDoc::FileParser::getLanguageId( 'mypath/myfile.as', $text );
    my $expected = 'as2';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_getFileInfo {
    my ($this) = @_;

    my $parser             = VisDoc::FileParser->new();
    my $here               = Cwd::abs_path . '/testfiles';
    my $path               = "$here/testgetInfo_as3.as";
    my ($modificationDate) = VisDoc::FileParser::_getFileInfo($path);
    my $result;
    my $expected;

    # modificationDate
    $result = $modificationDate;
    print("RES=$result.\n") if $debug;
    $this->assert( qr/^[0-9]{10}$/, $result );
}

sub test_parseCode {
    my ($this) = @_;

    my $here   = Cwd::abs_path . '/testfiles';
    my $path   = "$here/testcode_as3.as";
    my $parser = VisDoc::FileParser->new();
    my $text   = VisDoc::readFile($path);

    my $newText = $parser->_stubCode($text);

    {
        my $result   = $newText;
        my $expected = '/**
%VISDOC_STUB_CODE_BLOCK_1%
*/
package org.asaplibrary.data.array /*ehm*/{

	/**
	Array traverse options used by TraverseArrayEnumerator. The state options use bitwise operators, see ButtonStates for an example.
	%VISDOC_STUB_CODE_BLOCK_2%
	*/
	public class TraverseArrayOptions {
	
		public static const NONE:uint = 0; /**< The enumerator does nothing: 	%VISDOC_STUB_CODE_BLOCK_3% */
		
	}
}
';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test code block 1
        my $parseData = $parser->{data};
        my $key       = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_CODE_BLOCK, 1 );
        my $result   = $$parseData{codeBlocks}->{$key};
        my $expected = 'ABCDEF';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test code block 2
        my $parseData = $parser->{data};
        my $key       = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_CODE_BLOCK, 2 );
        my $result   = $$parseData{codeBlocks}->{$key};
        my $expected = '12345';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test code block 3
        my $parseData = $parser->{data};
        my $key       = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_CODE_BLOCK, 3 );
        my $result   = $$parseData{codeBlocks}->{$key};
        my $expected = 'zxcvb';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_parseJavadocComments {
    my ($this) = @_;

    my $here       = Cwd::abs_path . '/testfiles';
    my $path       = "$here/test_protect_elements.as";
    my $fileParser = VisDoc::FileParser->new();
    my $text       = VisDoc::readFile($path);

    my $newText = $fileParser->_stubJavadocComments($text);

    #use Data::Dumper;
    #print("fileParser=" . Dumper($fileParser->{data}));

    {
        my $result   = $newText;
        my $expected = '/*
XXXXXXXXXXXX
XXXXXXXXXXXX
XXXXXXXXXXXX
XXXXXXXXXXXX
*/


%VISDOC_STUB_JAVADOC_COMMENT_1%
// COMMENT
package org.asaplibrary.data.array /*ehm*/{ // COMMENT

	%VISDOC_STUB_JAVADOC_COMMENT_2%
	
	
	
	public class TraverseArrayOptions { // COMMENT
		// COMMENT
		public static const NONE:uint = 0; %VISDOC_STUB_JAVADOC_SIDE_3%
		public static const LOOP:uint = 1; %VISDOC_STUB_JAVADOC_SIDE_4%
		
		public function doit () : void {
			// COMMENT
		}
		
	}
}
';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc comment 1
        my $parseData = $fileParser->{data};
        my $key       = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_JAVADOC_COMMENT, 1 );
        my $result   = $$parseData{javadocComments}->{$key};
        my $expected = 'This is a class comment

<code>
ABCDEF
</code>


{@code Javadoc code}
End of comment.';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc comment 2
        my $parseData = $fileParser->{data};
        my $key       = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_JAVADOC_COMMENT, 2 );
        my $result = $$parseData{javadocComments}->{$key};
        my $expected =
'Array traverse options used by TraverseArrayEnumerator. The state options use bitwise operators, see ButtonStates for an example.
	Example:
	<![CDATA[yyyyyyyyyyyyy]]>
	<code>12345</code>';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc side comment 1
        my $parseData = $fileParser->{data};
        my $key       = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_JAVADOC_SIDE, 3 );
        my $result   = $$parseData{javadocComments}->{$key};
        my $expected = 'The enumerator does nothing: 	<code>zxcvb</code>';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc side comment 2
        my $parseData = $fileParser->{data};
        my $key       = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_JAVADOC_SIDE, 4 );
        my $result   = $$parseData{javadocComments}->{$key};
        my $expected = 'The enumerator loops past the last item.';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

sub test_parseQuotedStrings {
    my ($this) = @_;

    my $text    = 'abcdef"123456"ghijkl\'single\'end';
    my $parser  = VisDoc::FileParser->new();
    my $newText = $parser->_stubQuotedStrings($text);

    {
        my $result = $newText;
        my $expected =
'abcdef%VISDOC_STUB_QUOTED_STRING_1%ghijkl%VISDOC_STUB_QUOTED_STRING_2%end';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test quoted string 1
        my $parseData = $parser->{data};
        my $key       = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::VERBATIM_STUB_QUOTED_STRING, 1 );
        my $result   = $$parseData{quotedStrings}->{$key};
        my $expected = '"123456"';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test quoted string 2
        my $parseData = $parser->{data};
        my $key       = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::VERBATIM_STUB_QUOTED_STRING, 2 );
        my $result   = $$parseData{quotedStrings}->{$key};
        my $expected = "'single'";

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

sub test_parseQuotedStrings_with_commaSeparatedList {
    my ($this) = @_;

    my $text =
      'a,b,c,d,e,f,g,h,i    , j,k,l,m,n,o, p,"q", \'r\',s,t,u ,v, w,x ,y,z';
    my $parser    = VisDoc::FileParser->new();
    my $cleanText = $parser->_stubQuotedStrings($text);
    my @list = VisDoc::StringUtils::commaSeparatedListFromCommaSeparatedString(
        $cleanText);

    {
        my $result   = $list[25];
        my $expected = 'z';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_stubJavadocComments_direct {
    my ($this) = @_;

    my $text = '/** COMMENT */';

    my $parser = VisDoc::FileParser->new();
    my $result = $parser->_stubJavadocComments($text);

    my $expected = '%VISDOC_STUB_JAVADOC_COMMENT_1%';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stubJavadocSideComments_direct {
    my ($this) = @_;

    my $text = 'class A {
	var a:Number; /**< COMMENT */
}	';

    my $fileData = VisDoc::parseText( $text, 'as2' );

    my $result =
      $fileData->{packages}->[0]->{classes}->[0]->{properties}->[0]->{javadoc}
      ->getDescription();

    my $expected = 'COMMENT';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stubJavadocComments_indirect {
    my ($this) = @_;

    my $text = '/** COMMENT */
class A {}';

    my $fileData = VisDoc::parseText( $text, 'as2' );
    my $result =
      $fileData->{packages}->[0]->{classes}->[0]->{javadoc}->getDescription();

    my $expected = 'COMMENT';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_javadocCommentWithJavadocSideComment {
    my ($this) = @_;

    my $text = 'class A {
	
	/** AAA */
	var a:Number; /**< BBB */
}	';

    my $fileData = VisDoc::parseText( $text, 'as2' );

    my $result =
      $fileData->{packages}->[0]->{classes}->[0]->{properties}->[0]->{javadoc}
      ->getDescription();

    my $expected = 'AAA BBB';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stubCodeBlocks_direct {
    my ($this) = @_;

    my $text =
      '1111<code>xxxxxxxxxxxxxxx</code>2222<pre>yyyyyyyyyyyyyyyyy</pre>3333';

    my $parser = VisDoc::FileParser->new();
    my $result = $parser->_stubCodeBlocks($text);

    my $expected =
      '1111%VISDOC_STUB_CODE_BLOCK_1%2222%VISDOC_STUB_CODE_BLOCK_2%3333';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stubCodeBlocks_indirect {
    my ($this) = @_;

    my $text =
      '1111<code>xxxxxxxxxxxxxxx</code>2222<pre>yyyyyyyyyyyyyyyyy</pre>3333';

    my $parser = VisDoc::FileParser->new();

    my $newText = $parser->_stubCodeBlocks($text);
    my $blocks  = $parser->{data}->{codeBlocks};

    {
        my $result = $newText;
        my $expected =
          '1111%VISDOC_STUB_CODE_BLOCK_1%2222%VISDOC_STUB_CODE_BLOCK_2%3333';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {
        my $key = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_CODE_BLOCK, 1 );
        my $result   = $blocks->{$key};
        my $expected = 'xxxxxxxxxxxxxxx';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {
        my $key = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_CODE_BLOCK, 2 );
        my $result   = $blocks->{$key};
        my $expected = 'yyyyyyyyyyyyyyyyy';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_stubLinkTags_direct {
    my ($this) = @_;

    {
        my $text = '1111{@link SomeClass} 3333';

        my $parser = VisDoc::FileParser->new();

        my $result = $parser->_stubLinkTags($text);

        my $expected = '1111%VISDOC_STUB_INLINE_LINK_1% 3333';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    {
        my $text = '1111{@link SomeClass label &#125;} 3333';

        my $parser = VisDoc::FileParser->new();

        my $newText = $parser->_stubLinkTags($text);

        my $result   = $parser->{data}->getContentsOfLinkStub($newText);
        my $expected = '1111SomeClass label &#125; 3333';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_stubLinkTags_indirect {
    my ($this) = @_;

    my $text = '/**
Description text {@link com.visiblearea.SomeClass#method link label}.
@usage {@link OtherClass#method another link label}
*/
class SpeakingPets {
//
}';

    my $fileData = VisDoc::parseText($text);
    my $javadoc  = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};

    #use Data::Dumper;
    #print("javadoc=". Dumper($javadoc));

    {

        # link 0: package
        my $field    = $javadoc->{linkTags}->[0];
        my $result   = $field->{package};
        my $expected = 'com.visiblearea';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # link 0: class
        my $field    = $javadoc->{linkTags}->[0];
        my $result   = $field->{class};
        my $expected = 'SomeClass';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # link 0: member
        my $field    = $javadoc->{linkTags}->[0];
        my $result   = $field->{member};
        my $expected = 'method';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # link 0: label
        my $field    = $javadoc->{linkTags}->[0];
        my $result   = $field->{label};
        my $expected = 'link label';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_stubArray_direct {
    my ($this) = @_;

    my $text          = 'var id:Array = [1,2,3,4,5,6,7,8,9,10];';
    my $PATTERN_ARRAY = '
	\=\s*       # do only convert property values, not meta tags
	(\[.*?\])     # array content
	';

    my $parser = VisDoc::FileParser->new();

    my $result = $parser->stubArrays( $text, $PATTERN_ARRAY, 1 );
    my $expected = 'var id:Array = %VISDOC_STUB_ARRAY_1%;';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_stubArray_indirect {
    my ($this) = @_;

    my $text = 'class A {
	var id:Array = [1,2,3,4,5,6,7,8,9,10];
}';

    my $fileData = VisDoc::parseText( $text, 'as2' );

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    my $property =
      $fileData->{packages}->[0]->{classes}->[0]->{properties}->[0];
    {

        # test name
        my $result   = $property->{name};
        my $expected = 'id';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test dataType
        my $result   = $property->{dataType};
        my $expected = 'Array';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test value
        my $result   = $property->{value};
        my $expected = '[1,2,3,4,5,6,7,8,9,10]';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_replaceJavadocCommentsByStubs {
    my ($this) = @_;

    my $text = 'var some_member:int = 0; /**< xxxxxxxxxxxxx*yyyyyyyy */
	/**
	* This is a javadoc comment
	*/
	
/**
Second comment
*/

/** */
';

    my $parser = VisDoc::FileParser->new();

    my ( $newText, $blocks ) = $parser->_replaceJavadocCommentsByStubs($text);
    my $result   = $newText;
    my $expected = 'var some_member:int = 0; /**< xxxxxxxxxxxxx*yyyyyyyy */
	%VISDOC_STUB_JAVADOC_COMMENT_1%
	
%VISDOC_STUB_JAVADOC_COMMENT_2%

%VISDOC_STUB_JAVADOC_COMMENT_3%
';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
    {
        my $key = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_JAVADOC_COMMENT, 1 );
        my $result   = $blocks->{$key};
        my $expected = '* This is a javadoc comment';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_replaceJavadocSideCommentsByStubs {
    my ($this) = @_;

    my $text = 'var some_member:int = 0; /**< xxxxxxxxxxxxx*yyyyyyyy */
	/**
	* This is a javadoc comment
	*/
	
/**
Second comment
*/

/** */
';
    my $parser = VisDoc::FileParser->new();

    my ( $newText, $blocks ) =
      $parser->_replaceJavadocSideCommentsByStubs($text);
    my $result   = $newText;
    my $expected = 'var some_member:int = 0; %VISDOC_STUB_JAVADOC_SIDE_1%
	/**
	* This is a javadoc comment
	*/
	
/**
Second comment
*/

/** */
';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );

    {
        my $key = VisDoc::StringUtils::getStubKey(
            $VisDoc::StringUtils::STUB_JAVADOC_SIDE, 1 );
        my $result   = $blocks->{$key};
        my $expected = 'xxxxxxxxxxxxx*yyyyyyyy';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_getContents {
    my ($this) = @_;

    my $text = '	/**
	* "About speaking pets"
	* <code>
	* new SpeakingPets();
	* <![CDATA[cdata]]>
	* </code>
	* or
	* {@code new SpeakingPets();}
	* @use
	* Usage...
	*/
	public class SpeakingPets
	{
		
	}
}
';

    my $fileParser = VisDoc::FileParser->new();
    my $fileData   = $fileParser->parseText( $text, 'as3' );
    my $classes    = $fileData->{packages}->[0]->{classes};

    #use Data::Dumper;
    #print("classes=" . Dumper($classes) . "\n");

    my $textWithStubs = $classes->[0]->{javadoc}->getDescription();
    my $original      = $fileParser->getContents($textWithStubs);

    my $result   = $original;
    my $expected = '"About speaking pets"
<pre>
<span class="codeKeyword">new</span> SpeakingPets();
<![CDATA[cdata]]>
</pre>
or
<code><span class="codeKeyword">new</span> SpeakingPets();</code>';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );

}

=pod

=cut

sub test_include_as2 {
    my ($this) = @_;

    my $here = Cwd::abs_path . '/testfiles';
    my $path = "$here/include_as2/MainClass.as";

    my $fileData = VisDoc::parseFile($path);

    #use Data::Dumper;
    #print(Dumper($fileData));

    {

        # included method 1
        my $method = $fileData->{packages}->[0]->{classes}->[0]->{methods}->[1];
        {

            # test method name
            my $result   = $method->{name};
            my $expected = 'includedMethod';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
        {

            # test method access
            my $result   = $method->{access}->[0];
            my $expected = 'public';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
        {

            # test method javadoc description
            my $result   = $method->{javadoc}->getDescription();
            my $expected = 'This method is included from another file.';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
    }
    {

        # included method 2
        my $method = $fileData->{packages}->[0]->{classes}->[0]->{methods}->[2];
        {

            # test method name
            my $result   = $method->{name};
            my $expected = 'anotherIncludedMethod';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
        {

            # test method access
            my $result   = $method->{access}->[0];
            my $expected = 'private';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
    }
    {

        # included method 3
        my $method = $fileData->{packages}->[0]->{classes}->[0]->{methods}->[3];
        {

            # test method name
            my $result   = $method->{name};
            my $expected = 'thirdIncludedMethod';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
    }
}

=pod

=cut

sub test_include_as3 {
    my ($this) = @_;

    my $here = Cwd::abs_path . '/testfiles';
    my $path = "$here/include_as3/one_level_deeper/MainClass.as";

    my $fileData = VisDoc::parseFile($path);

    #use Data::Dumper;
    #print(Dumper($fileData));

    {

        # included method 1
        my $method = $fileData->{packages}->[0]->{classes}->[0]->{methods}->[1];
        {

            # test method name
            my $result   = $method->{name};
            my $expected = 'includedMethod';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
        {

            # test method access
            my $result   = $method->{access}->[0];
            my $expected = 'public';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
        {

            # test method javadoc description
            my $result   = $method->{javadoc}->getDescription();
            my $expected = 'This method is included from another file.';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
    }
    {

        # included method 2
        my $method = $fileData->{packages}->[0]->{classes}->[0]->{methods}->[2];
        {

            # test method name
            my $result   = $method->{name};
            my $expected = 'anotherIncludedMethod';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
        {

            # test method access
            my $result   = $method->{access}->[0];
            my $expected = 'private';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
    }
    {

        # included method 3
        my $method = $fileData->{packages}->[0]->{classes}->[0]->{methods}->[3];
        {

            # test method name
            my $result   = $method->{name};
            my $expected = 'thirdIncludedMethod';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
    }
}

=pod

=cut

sub test_tag_private_class_as2 {
    my ($this) = @_;

    my $text = '/**
@private
*/
class A {}
';
    my $fileData  = VisDoc::parseText( $text, 'as2' );
    my $classData = $fileData->{packages}->[0]->{classes}->[0];
    my $result    = $classData->isPublic();
    my $expected  = 0;

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_tag_private_member_as2 {
    my ($this) = @_;

    my $text = 'class A {
	
	/**
	@private
	*/
	function b () : Void {}

}
';
    my $fileData   = VisDoc::parseText( $text, 'as2' );
    my $methodData = $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0];
    my $result     = $methodData->isPublic();
    my $expected   = 0;

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_tag_private_class_as3 {
    my ($this) = @_;

    my $text = 'package {

/**
@private
*/
public class A {}

}
';
    my $fileData  = VisDoc::parseText( $text, 'as3' );
    my $classData = $fileData->{packages}->[0]->{classes}->[0];
    my $result    = $classData->isPublic();
    my $expected  = 0;

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_tag_private_member_as3 {
    my ($this) = @_;

    my $text = 'package {

class A {
	
	/**
	@private
	*/
	public function b () : Void {}

}

}
';
    my $fileData   = VisDoc::parseText( $text, 'as3' );
    my $methodData = $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0];
    my $result     = $methodData->isPublic();
    my $expected   = 0;

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_tag_private_class_java {
    my ($this) = @_;

    my $text = 'package b;
/**
@private
*/
public class A {}
';
    my $fileData  = VisDoc::parseText( $text, 'java' );
    my $classData = $fileData->{packages}->[0]->{classes}->[0];
    my $result    = $classData->isPublic();
    my $expected  = 0;

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_tag_private_class_as3_no_tag {
    my ($this) = @_;

    my $text = 'package {

private class A {}

}';
    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $classData = $fileData->{packages}->[0]->{classes}->[0];

    my $result   = $classData->isPublic();
    my $expected = 0;

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

1;
