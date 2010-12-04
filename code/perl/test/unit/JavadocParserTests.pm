use strict;
use warnings;
use diagnostics;

package JavadocParserTests;
use base qw(Test::Unit::TestCase);

use VisDoc;
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

sub test_getFieldNameParts {
    my ($this) = @_;

    my $text = '@author John Doe
@description This class also belongs to package blo.';

    my $parser = VisDoc::JavadocParser->new();
    my ( $firstLine, $fieldNameParts ) =
      VisDoc::JavadocParser->_getFieldNameParts($text);

    {

        # test firstLine
        my $result   = $firstLine;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test author
        my $result   = $$fieldNameParts[0];
        my $expected = 'author John Doe';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test description
        my $result   = $$fieldNameParts[1];
        my $expected = 'description This class also belongs to package blo.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_getFieldNameParts_firstline {
    my ($this) = @_;

    my $text = 'This is the introduction
@author John Doe
@description This class also belongs to package blo.';

    my $parser = VisDoc::JavadocParser->new();
    my ( $firstLine, $fieldNameParts ) =
      VisDoc::JavadocParser->_getFieldNameParts($text);

    {

        # test firstLine
        my $result   = $firstLine;
        my $expected = 'This is the introduction';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_getFieldNameParts_empty {
    my ($this) = @_;

    my $text = 'This is the introduction';

    my $parser = VisDoc::JavadocParser->new();
    my ( $firstLine, $fieldNameParts ) =
      VisDoc::JavadocParser->_getFieldNameParts($text);

    {

        # test firstLine
        my $result   = $firstLine;
        my $expected = 'This is the introduction';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test array
        my $result   = scalar @$fieldNameParts;
        my $expected = 0;
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_getFieldNameParts_params {
    my ($this) = @_;

    my $text = '@param inText: the text to be processed
@param list The list to populate
@param effect (optional): effect to apply to members
@return The list.';

    my $parser = VisDoc::JavadocParser->new();
    my ( $firstLine, $fieldNameParts ) =
      VisDoc::JavadocParser->_getFieldNameParts($text);

    {

        # test firstLine
        my $result   = $firstLine;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test param 1
        my $result   = $$fieldNameParts[0];
        my $expected = 'param inText: the text to be processed';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test param 3
        my $result   = $$fieldNameParts[2];
        my $expected = 'param effect (optional): effect to apply to members';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test return
        my $result   = $$fieldNameParts[3];
        my $expected = 'return The list.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_description_anonymous {
    my ($this) = @_;

    my $text = 'Description text.';

    my $parser = VisDoc::JavadocParser->new();
    $parser->parse($text);

    my $fields   = $parser->{data}->fieldsWithName('description');
    my $result   = $fields->[0]->{value};
    my $expected = 'Description text.';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

sub test_description_with_anonymous {
    my ($this) = @_;

    my $text = 'This is the first line. 
@description
This also belongs to the description.
@description Second description field';

    my $parser = VisDoc::JavadocParser->new();
    $parser->parse($text);

    my $result = $parser->{data}->getDescription();
    my $expected =
'This is the first line. This also belongs to the description. Second description field';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

sub test_description_empty {
    my ($this) = @_;

    my $text = '@author Jonathan';

    my $parser = VisDoc::JavadocParser->new();
    $parser->parse($text);

    my $fields   = $parser->{data}->fieldsWithName('description');
    my $result   = $fields->[0]->{value} || '';
    my $expected = '';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );

}

sub test_fieldsWithName {
    my ($this) = @_;

    my $text = '@author
@description: This also belongs to the description.
@see A
@see B
@see C';

    my $parser = VisDoc::JavadocParser->new();
    $parser->parse($text);
    my $javadocData = $parser->{data};

    #use Data::Dumper;
    #print("javadocData=" . Dumper($javadocData));

    {

        # test field author
        my $fields   = $javadocData->fieldsWithName('author');
        my $result   = $fields->[0]->{value};
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test field description
        my $fields   = $javadocData->fieldsWithName('description');
        my $result   = $fields->[0]->{value};
        my $expected = 'This also belongs to the description.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test field see 1
        my $fields   = $javadocData->fieldsWithName('see');
        my $result   = $fields->[0]->{class};
        my $expected = 'A';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test field see 2
        my $fields   = $javadocData->fieldsWithName('see');
        my $result   = $fields->[1]->{class};
        my $expected = 'B';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_tag_see {
    my ($this) = @_;

    my $text = 'package {

/**
Main description text: {@link #draw(drawObject) have a look at method draw}.
@see "Colin Moock: Essential ActionScript 2.0, p. 100"
@see <a href="http://java.sun.com/j2se/1.5.0/docs/tooldocs/windows/javadoc.html">javadoc specification</a>
@see #draw(drawObject)
@see ReferencedClass#paint()
@see ReferencedClass#draw Draw it
@see com.visiblearea.util.UtilClass#makeLifeEasy()
@see UtilClass#makeLifeEasy()
*/
class A {}

}';

    my $fileData    = VisDoc::parseText( $text, 'as3' );
    my $javadoc     = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};
    my $description = $javadoc->getDescription();
    my $fields      = $javadoc->fieldsWithName('see');

    #use Data::Dumper;
    #print("fields=" . Dumper($fields));

    {

        # test field see 0
        my $result   = $fields->[0]->{label};
        my $expected = 'Colin Moock: Essential ActionScript 2.0, p. 100';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test field see 1
        my $result = $fields->[1]->{label};
        my $expected =
'<a href="http://java.sun.com/j2se/1.5.0/docs/tooldocs/windows/javadoc.html">javadoc specification</a>';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test field see 2: method
        my $result   = $fields->[2]->{member};
        my $expected = 'draw';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test field see 2: params
        my $result   = $fields->[2]->{params};
        my $expected = 'drawObject';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

=pod
	{
		# test field see 2: qualifiedName
		my $result = $fields->[2]->{qualifiedName};
		my $expected = 'draw(drawObject)';
		print("RES=$result.\n")     if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
=cut

    {

        # test field see 3: class
        my $result   = $fields->[3]->{class};
        my $expected = 'ReferencedClass';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test field see 3: method
        my $result   = $fields->[3]->{member};
        my $expected = 'paint';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test field see 4: label
        my $result   = $fields->[4]->{label};
        my $expected = 'Draw it';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test field see 5: package
        my $result   = $fields->[5]->{package};
        my $expected = 'com.visiblearea.util';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test field see 6: class
        my $result   = $fields->[5]->{class};
        my $expected = 'UtilClass';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_tag_throws {
    my ($this) = @_;

    my $text = 'package {

	class A {
	
		/**
		Main description text.
		@throws SeriousException
		*/
		public function a () {}
	}
}';

    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $javadoc =
      $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{javadoc};
    my $fields = $javadoc->fieldsWithName('throws');

    #use Data::Dumper;
    #print("fields=" . Dumper($fields));

    {

        # test field throws
        my $result   = $fields->[0]->{class};
        my $expected = 'SeriousException';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_tag_exception {
    my ($this) = @_;

    my $text = 'package {

	class A {
	
		/**
		Main description text.
		@exception SeriousException
		*/
		public function a () {}
	}
}';

    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $javadoc =
      $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{javadoc};
    my $fields = $javadoc->fieldsWithName('exception');

    #use Data::Dumper;
    #print("fields=" . Dumper($fields));

    {

        # test field throws
        my $result   = $fields->[0]->{class};
        my $expected = 'SeriousException';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod
sub test_tag_overload {
    my ($this) = @_;

	my $text = 'package {

	class A {
	
		/**
		Main description text.
		@overload #drawByFillAndLineColor
		@overload #drawByFillColor
		*/
		public function a () {}
	}
}';
	my $fileData = VisDoc::parseText($text, 'as3');
	my $javadoc = $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{javadoc};
	my $fields = $javadoc->fieldsWithName('overload');
	
#use Data::Dumper;
#print("fields=" . Dumper($fields));

	{
		# test field throws
		my $result = $fields->[1]->{member};
		my $expected = 'drawByFillColor';
		print("RES=$result.\n")     if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
	
}
=cut

=pod

=cut

=pod
sub test_addField {
    my ($this) = @_;

	my $text = '@author
@description: This also belongs to the description.
@see A
@see B
@see C';

	my $parser = VisDoc::JavadocParser->new();
	$parser->parse($text);
	
	$parser->_addField('see', 'D');
	
	{
		# test field see 4
		my $fields = $parser->{data}->fieldsWithName('see');
		my $result = $fields->[3]->{value};
		my $expected = 'D';
		print("RES=$result.\n")     if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
}
=cut

=pod

=cut

sub test_tag_param {
    my ($this) = @_;

    my $text = 'package {

/**
Main description text.
@param inDrawClip:    the MovieClip to draw into
@param inStartX:      the x position where drawing starts
@param inStartY:      the y position where drawing starts
@param inLineWidth:   (optional) the width of the drawn line in pixels. If not specified, a line width of 1 pixel is assumed.
*/

class A {}

}';

}

sub test_tag_sends {
    my ($this) = @_;

    my $text = 'package {

	/**
	Main description text.
	@sends #onLoadProgress(name:String, total:Number, loaded:Number, this:Loader) during loading
	@sends "onLoadProgress(name:String, total:Number, loaded:Number, this:Loader) during loading"
	@sends SomeEvent#onChangeFocus when a change of focus is detected
	*/
	class A {}

}';

    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $javadoc  = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};
    my $fields   = $javadoc->fieldsWithName('sends');

    #use Data::Dumper;
    #print("fields=" . Dumper($fields));

    {

        # sends field 0: method
        my $result   = $fields->[0]->{member};
        my $expected = 'onLoadProgress';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # sends field 0: params
        my $result   = $fields->[0]->{params};
        my $expected = 'name:String,total:Number,loaded:Number,this:Loader';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # sends field 0: label
        my $result   = $fields->[0]->{label};
        my $expected = 'during loading';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # sends field 1
        my $result = $fields->[1]->{label};
        my $expected =
'onLoadProgress(name:String, total:Number, loaded:Number, this:Loader) during loading';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # sends field 2
        my $result   = $fields->[2]->{label};
        my $expected = 'when a change of focus is detected';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_tag_in_middle_of_sentence {
    my ($this) = @_;

    my $text = '
	/**
	* Line 1.
	* Testing a variety of @see values.
	* @author me
	*/
	class A {}
';
    my $fileData = VisDoc::parseText( $text, 'as2' );
    my $javadoc = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};

    #use Data::Dumper;
    #print("javadoc=" . Dumper($javadoc) . "\n");

    {

        # tag 'see' should not exist
        my $result = $javadoc->fieldsWithName('see');
        $this->assert_null($result);
    }
    {

        # test first field
        my $fields   = $javadoc->fieldsWithName('author');
        my $result   = $fields->[0]->{value};
        my $expected = 'me';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test description
        my $result   = $javadoc->getDescription();
        my $expected = 'Line 1.
Testing a variety of @see values.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod
sub test_getDescriptionParts_5 {
    my ($this) = @_;

	my $text = '/**
Testing @see references, see {@link #aFunction a number of @see examples}.
{@code test code text}
*/
class A {}
';

	my $fileData = VisDoc::parseText($text, 'as2');
	my $description = $fileData->{packages}->[0]->{classes}->[0]->{javadoc}->getDescription();
	my ($beforeFirstLineTag, $summaryLine, $rest) = $fileData->getDescriptionParts($description);
	
#print("description=$description\n");
#print("beforeFirstLineTag=$beforeFirstLineTag\n");
#print("summaryLine=$summaryLine\n");
#print("rest=$rest\n");

	{
		# test tag before summary line	
		my $result = $beforeFirstLineTag;
		my $expected = '';
		print("RES=$result.\n")     if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
	{
		# test summary line	
		my $result = $summaryLine;
		my $expected = 'Testing @see references, see <a href="A.html#aFunction" class="private">a number of @see examples</a>.';
		print("RES=$result.\n")     if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
	{
		# test rest	
		my $result = $rest;
		my $expected = '
<code>test code text</code>';
		print("RES=$result.\n")     if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
}
=cut

sub test_tag_link {
    my ($this) = @_;

    my $text = 'package {
/**
This is a description.
{@link test}
{@link org.asaplibrary.data.array.Iterator#next Get next value}
{@link #previous Get previous value}
{@link #previous(input:int) Get previous value}
Testing @see references, see {@link #aFunction a number of @see examples}.
*/
class A {
	function previous () {}
	function previous (input:int) {}
	function aFunction () {}
}
}
';
    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $javadoc = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData) . "\n");

    # link 1
    {

        # package
        my $result   = $javadoc->{linkTags}->[1]->{package};
        my $expected = 'org.asaplibrary.data.array';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # class
        my $result   = $javadoc->{linkTags}->[1]->{class};
        my $expected = 'Iterator';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # member
        my $result   = $javadoc->{linkTags}->[1]->{member};
        my $expected = 'next';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # label
        my $result   = $javadoc->{linkTags}->[1]->{label};
        my $expected = 'Get next value';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # link 2
    {

        # member
        my $result   = $javadoc->{linkTags}->[2]->{member};
        my $expected = 'previous';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # qualifiedName
        my $result   = $javadoc->{linkTags}->[2]->{qualifiedName};
        my $expected = 'previous';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # label
        my $result   = $javadoc->{linkTags}->[2]->{label};
        my $expected = 'Get previous value';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # link 3
    {

        # member
        my $result   = $javadoc->{linkTags}->[3]->{member};
        my $expected = 'previous';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

=pod
	{
		# qualifiedName
		my $result   = $javadoc->{linkTags}->[3]->{qualifiedName};
		my $expected = 'previous(input:int)';
		print("RES=$result.\n")     if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
=cut

    {

        # label
        my $result   = $javadoc->{linkTags}->[3]->{label};
        my $expected = 'Get previous value';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # link 4
    {

        # member
        my $result   = $javadoc->{linkTags}->[4]->{member};
        my $expected = 'aFunction';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # label
        my $result   = $javadoc->{linkTags}->[4]->{label};
        my $expected = 'a number of @see examples';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_tag_linkplain {
    my ($this) = @_;

    my $text = 'package {
/**
This is a description.
{@linkplain test}
{@linkplain org.asaplibrary.data.array.Iterator#next Get next value}
{@linkplain #previous Get previous value}
*/
class A {}
}
';
    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $javadoc = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData) . "\n");

    # link 1
    {

        # package
        my $result   = $javadoc->{linkTags}->[1]->{package};
        my $expected = 'org.asaplibrary.data.array';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # class
        my $result   = $javadoc->{linkTags}->[1]->{class};
        my $expected = 'Iterator';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # member
        my $result   = $javadoc->{linkTags}->[1]->{member};
        my $expected = 'next';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # label
        my $result   = $javadoc->{linkTags}->[1]->{label};
        my $expected = 'Get next value';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # link 2
    {

        # member
        my $result   = $javadoc->{linkTags}->[2]->{member};
        my $expected = 'previous';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # label
        my $result   = $javadoc->{linkTags}->[2]->{label};
        my $expected = 'Get previous value';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_tag_literal {
    my ($this) = @_;

    my $text = 'package {
/**
1111{@literal <div class="visibleareaBlock"><code>contents</code></div>}3333
*/
class A {}
}
';

    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $javadoc = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};

    my $result   = $javadoc->getDescription();
    my $expected = '1111%VISDOC_STUB_TAG_LITERAL_2%3333';

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_tag_code {
    my ($this) = @_;

    my $text = 'package {
/**
1111{@code class B} 3333
*/
class A {}
}
';

    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $javadoc = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};

    my $result   = $javadoc->getDescription();
    my $expected = '1111%VISDOC_STUB_TAG_CODE_1% 3333';

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_tag_img {
    my ($this) = @_;

    my $text = 'package {
/**
1111{@img imagename.jpg}3333
*/
class A {}
}
';
    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $javadoc  = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};
    my $result   = $javadoc->getDescription();
    my $expected = '1111<img src="../img/imagename.jpg" alt="imagename.jpg" />3333';

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_tag_inheritDoc {
    my ($this) = @_;

    my $text1 = '
	public class Shape implements Serializable, delegatepackage.Delegate /* classpath access */, ExtendedObject { {
	
		/**
		Description from class Shape.
		@param myTag This is very much alike Objective-C.
		*/
		public function retainCount () : Number
		{
			//
		}
		
		public function setDelegate (inDelegate:Object) : Void
		{}
	}';

    my $text2 = '
	public class Rectangle extends Shape {
	
		/**
		Custom Rectangle comment. After this line the inherited comment from class Shape should be inserted. {@inheritDoc} Just two random links for testing: {@link Circle} and {@link Circle#retainCount}
		@return Custom Rectangle return comment. After this line the comment from class Shape should be inserted. {@inheritDoc}
		@param myTag {@inheritDoc}
		*/
		public function retainCount () : Number
		{
			//
		}
	}';

    my $text3 = '
	public class Square extends Rectangle {
	
		/**
		Some. {@inheritDoc}
		*/
		public function retainCount () : Number
		{
			//
		}
	}';

    my $text4 = '
	public class Circle extends Shape {
	
		public function retainCount () : Number
		{
			//
		}
	}';

    my $text5 = 'interface delegatepackage.Delegate {
	
	/**
	This comment is written in class {@link delegatepackage.Delegate}.
	I jumped to my feet, completely thunderstruck.
	@param inDelegate : the delegate object
	*/
	public function setDelegate (inDelegate:Object) : Void;
}';

    my @texts = ( $text1, $text2, $text3, $text4, $text5 );

    my $fileData = VisDoc::parseTexts( \@texts, 'as2' );

    {

        # class Shape, method setDelegate: description
        my $javadoc =
          $fileData->[0]->{packages}->[0]->{classes}->[0]->{methods}->[1]
          ->{javadoc};

        my $result = $javadoc->getDescription();
        my $expected =
'<div class="inheritDoc">This comment is written in class <a href="delegatepackage_Delegate.html">delegatepackage.Delegate</a>.
	I jumped to my feet, completely thunderstruck. <span class="inheritDocLink"><a href="delegatepackage_Delegate.html#setDelegate">&rarr;</a></span></div>';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    {

        # class Rectangle, method retainCount: description        
        my $javadoc =
          $fileData->[0]->{packages}->[0]->{classes}->[3]->{methods}->[0]
          ->{javadoc};

        my $result = $javadoc->getDescription();
        my $expected =
'Custom Rectangle comment. After this line the inherited comment from class Shape should be inserted. <div class="inheritDoc">Description from class Shape. <span class="inheritDocLink"><a href="Shape.html#retainCount">&rarr;</a></span></div> Just two random links for testing: <a href="Circle.html">Circle</a> and <a href="Circle.html#retainCount">Circle.retainCount</a>';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    {
        # class Rectangle, method retainCount: param
        my $javadoc =
          $fileData->[0]->{packages}->[0]->{classes}->[3]->{methods}->[0]
          ->{javadoc};

        my $paramField = $javadoc->{params}->[0];
        my $result     = $paramField->{value};
        my $expected =
'<div class="inheritDoc">This is very much alike Objective-C. <span class="inheritDocLink"><a href="Shape.html#retainCount">&rarr;</a></span></div>';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    {

        # class Square, method retainCount: description
        my $javadoc =
          $fileData->[0]->{packages}->[0]->{classes}->[2]->{methods}->[0]
          ->{javadoc};

        my $result = $javadoc->getDescription();
        my $expected =
'Some. <div class="inheritDoc">Custom Rectangle comment. After this line the inherited comment from class Shape should be inserted. <div class="inheritDoc">Description from class Shape. <span class="inheritDocLink"></span></div> Just two random links for testing: <a href="Circle.html">Circle</a> and <a href="Circle.html#retainCount">Circle.retainCount</a> <span class="inheritDocLink"><a href="Rectangle.html#retainCount">&rarr;</a></span></div>';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    {

        # class Circle, method retainCount: description (automatic)
        my $javadoc =
          $fileData->[0]->{packages}->[0]->{classes}->[1]->{methods}->[0]
          ->{javadoc};

        my $result = $javadoc->getDescription();
        my $expected =
'<div class="inheritDoc">Description from class Shape. <span class="inheritDocLink"><a href="Shape.html#retainCount">&rarr;</a></span></div>';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_params {
    my ($this) = @_;

    my $text = 'package {
	
	/**
	@param inText: the text to be processed
@param list The list to populate
@param effect (optional) effect to apply to members
@return The list.
*/
class A {}
}
';

    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $javadoc  = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};
    my $params   = $javadoc->{params};

    #use Data::Dumper;
    #print("params=" . Dumper($params));

    {

        # test params 0: name
        my $result   = $params->[0]->{name};
        my $expected = 'inText';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test params 0: value
        my $result   = $params->[0]->{value};
        my $expected = 'the text to be processed';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test params 1: name
        my $result   = $params->[1]->{name};
        my $expected = 'list';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test params 1: value
        my $result   = $params->[1]->{value};
        my $expected = 'The list to populate';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test params 2: name
        my $result   = $params->[2]->{name};
        my $expected = 'effect';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test params 2: value
        my $result   = $params->[2]->{value};
        my $expected = '(optional) effect to apply to members';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_return {
    my ($this) = @_;

    my $text = 'package {
	
	/**
	@param inText: the text to be processed
@param list The list to populate
@param effect (optional) effect to apply to members
@return The list.
*/
class A {}
}
';

    my $fileData = VisDoc::parseText( $text, 'as3' );
    my $javadoc  = $fileData->{packages}->[0]->{classes}->[0]->{javadoc};
    my $fields   = $javadoc->fieldsWithName('return');

    #use Data::Dumper;
    #print("fields=" . Dumper($fields));

    {

        # test name
        my $result   = $fields->[0]->{name};
        my $expected = 'return';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test value
        my $result   = $fields->[0]->{value};
        my $expected = 'The list.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}
1;
