use strict;
use warnings;
use diagnostics;

package ParserTests;
use base qw(Test::Unit::TestCase);

use VisDoc;
use VisDoc::FileParser;
use VisDoc::ParserBase;
use VisDoc::ParserAS2;
use VisDoc::ParserAS3;
use VisDoc::ParserJava;
use VisDoc::MethodData;
use VisDoc::PropertyData;

my $debug = 0;

sub new {
    my $self = shift()->SUPER::new(@_);

    return $self;
}

sub set_up {
    my ($this) = @_;

    VisDoc::FileData::initLinkDataRefs();
}

sub test_parseClassData_as2 {
    my ($this) = @_;

    my $text = '
/**
The first sentence of the class description is the class summary.
*/
	class com.visiblearea.SpeakingPets
	extends Sprite
	implements IAnimal, ISprite
	{
		//
	}';

    my $fileParser = VisDoc::FileParser->new();
    my $fileData   = $fileParser->parseText( $text, 'as2' );
    my $classes    = $fileData->{packages}->[0]->{classes};
    my $classData  = $classes->[0];

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test package (classpath)
        my $result   = $classData->{classpath};
        my $expected = 'com.visiblearea.SpeakingPets';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test description
        my $result = $classData->{javadoc}->getDescription();
        my $expected =
          'The first sentence of the class description is the class summary.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class name
        my $result   = $classData->{name};
        my $expected = 'SpeakingPets';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test type
        my $result   = $classData->{type};
        my $expected = $VisDoc::ClassData::TYPE->{'CLASS'};
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test acccess
        my $result = $classData->{access}[0];
        $this->assert_null($result);
    }
    {

        # test is public
        my $result   = $classData->isPublic();
        my $expected = 1;
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test superClass
        my $result   = $classData->{superclasses}->[0]->{name};
        my $expected = 'Sprite';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test interface
        my $result   = $classData->{interfaces}->[0]->{name};
        my $expected = 'IAnimal';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc

=pod
		my $result = $classData->{javadocStub};
		my $expected = '%VISDOC_STUB_JAVADOC_COMMENT_1%';
		print("RES=$result.\n")     if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
=cut

    }
}

=pod

=cut

sub test_parseClassData_as3 {
    my ($this) = @_;

    my $text = '
	
	%VISDOC_STUB_JAVADOC_COMMENT_1%
	
	public class SpeakingPets extends Sprite implements IAnimal, ISprite
	{
		public function SpeakingPets()
		{
			var pets:Array = [new Cat(), new Dog()]; /**< Instantiate empty list of basic pets. */
			for each (var pet:* in pets)
			{
				command(pet);
			}
		}
		var customItem:CustomClass = new CustomClass()
	}';
    my $fileParser = VisDoc::FileParser->new();
    my $parser     = $fileParser->getParserForLanguage('as3');
    $parser->parseClasses($text);
    my $classes = $parser->{classes};

    {

        # test class name
        my $result   = $classes->[0]->{name};
        my $expected = 'SpeakingPets';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test type
        my $result   = $classes->[0]->{type};
        my $expected = $VisDoc::ClassData::TYPE->{'CLASS'};
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test acccess
        my $result   = $classes->[0]->{access}[0];
        my $expected = 'public';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test superClass
        my $result   = $classes->[0]->{superclasses}->[0]->{name};
        my $expected = 'Sprite';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test interface 1
        my $result   = $classes->[0]->{interfaces}->[0]->{name};
        my $expected = 'IAnimal';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test interface 2
        my $result   = $classes->[0]->{interfaces}->[1]->{name};
        my $expected = 'ISprite';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc

=pod
		my $result = $classes->[0]->{javadocStub};
		my $expected = '%VISDOC_STUB_JAVADOC_COMMENT_1%';
		print("RES=$result.\n")     if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
=cut

    }
}

=pod

=cut

sub test_parseClassData_as3_interface {
    my ($this) = @_;

    my $text = '
	package org.casalib.collection {
	
	/**
		Interface for list collections.
		
		@author Aaron Clinger
		@author Dave Nelson
		@version 06/04/09
	*/
	public interface IList {
		
		
		/**
			Appends the specified item to the end of this list.
			
			@param item: Element to be inserted.
			@return Returns <code>true</code> if the list was changed as a result of the call; otherwise <code>false</code>.
		*/
		function addItem(item:*):Boolean;
		
		/**
			Inserts an item as a specified position.
			
			@param item: Element to be inserted.
			@param index: Position where the elements should be added.
			@return Returns <code>true</code> if the list was changed as a result of the call; otherwise <code>false</code>.
		*/
		function addItemAt(item:*, index:int):Boolean;
		
	}
}';
    my $fileParser = VisDoc::FileParser->new();
    my $fileData   = $fileParser->parseText($text);
    my $classData  = $fileData->{packages}->[0]->{classes}->[0];

    #use Data::Dumper;
    #print("classData=" . Dumper($classData));


    {

        # test interface name
        my $result   = $classData->{name};
        my $expected = 'IList';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 0: name
        my $result   = $classData->{methods}->[0]->{name};
        my $expected = 'addItem';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 0: returnType
        my $result   = $classData->{methods}->[0]->{returnType};
        my $expected = 'Boolean';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 1: desciption
        my $result   = $classData->{methods}->[1]->{javadoc}->getDescription();
        my $expected = 'Inserts an item as a specified position.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_parseClassData_java {
    my ($this) = @_;

    my $text = '
	
	%VISDOC_STUB_JAVADOC_COMMENT_1%
	
	public abstract class RawMembers<T> extends ColoredPoint implements Paintable, java.io.Serializable, Collection<String>
	{
		public static void main(String[] args) { 
			RawMembers rw = null; 
			Collection<Number> cn = rw.myNumbers(); // ok 
			Iterator<String> is = rw.iterator(); // unchecked warning 
			Collection<NonGeneric> cnn = rw.cng; // ok - static member 
	    }
	    
	    public Paint getFilling(TMNodeAdapter nodeAdapter)
			throws TMExceptionBadTMNodeKind {
			
			TMNode node = nodeAdapter.getNode();
			if (node instanceof TMFileNode) {
				TMFileNode fNode = (TMFileNode) node;
				long time = fNode.getDate();
				long diff = (new Date()).getTime() - time;
				if (diff <= 3600000L) {             // less than an hour
					nodeAdapter.setUserData("Less than an hour");
					return Color.white;
				} else if (diff <= 86400000L) {     // less than a day
					nodeAdapter.setUserData("Less than a day");
					return Color.green;
				} else if (diff <= 604800000L) {    // less than a week
					nodeAdapter.setUserData("Less than a week");
					return Color.yellow;
				} else if (diff <= 2592000000L) {   // less than a month
					nodeAdapter.setUserData("Less than a month");
					return Color.orange;
				} else if (diff <= 31536000000L) {  // less than a year
					nodeAdapter.setUserData("Less than a year");
					return Color.red;
				} else {                           // more than a year
					nodeAdapter.setUserData("More than a year");
					return Color.blue;
				}
			} else {
				throw new TMExceptionBadTMNodeKind(this, node);
			}
		}
		
	    List toList(Collection c) {...}
		
		public SFSEvent(String name, SFSObject params)
		{
			this.name = name;
			this.params = params;
		}
		
		public String getName()
		{
			return name;
		}
		
		public SFSObject getParams()
		{
			return params;
		}
		
		@Override
		public String toString()
		{
			return "Type: " + this.name + "\nParams: " + this.params.toString();
		}
		
	    private static final char MSG_JSON = "{";

		%VISDOC_STUB_JAVADOC_COMMENT_1%
		public static final String XTMSG_TYPE_XML = "xml";
		
		private Map<Integer, Room> roomList;
		
		int activeRoomId = -1;
		
		static Collection<NonGeneric> cng = new ArrayList<NonGeneric>();
		
		public static final String onUserVariablesUpdate = "onUserVariablesUpdate";

		private String name;
		private SFSObject params;
	}';

    my $fileData = VisDoc::parseText( $text, 'java' );
    my $classData = $fileData->{packages}->[0]->{classes}->[0];

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test class name
        my $result   = $classData->{name};
        my $expected = 'RawMembers<T>';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test type
        my $result   = $classData->{type};
        my $expected = $VisDoc::ClassData::TYPE->{'CLASS'};
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test acccess 1
        my $result   = $classData->{access}[0];
        my $expected = 'public';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test acccess 1
        my $result   = $classData->{access}[1];
        my $expected = 'abstract';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test throws
        my $result   = $classData->{methods}->[1]->{exceptionType};
        my $expected = 'TMExceptionBadTMNodeKind';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test superClass
        my $result   = $classData->{superclasses}->[0]->{name};
        my $expected = 'ColoredPoint';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test interface 1
        my $result   = $classData->{interfaces}->[0]->{name};
        my $expected = 'Paintable';
        print("RES=interface 1=$result.\n") if $debug;
        print("EXP=$expected.\n")           if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test interface 2: name
        my $result   = $classData->{interfaces}->[1]->{name};
        my $expected = 'Serializable';
        print("RES=interface 2=$result.\n") if $debug;
        print("EXP=$expected.\n")           if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test interface 2: classpath
        my $result   = $classData->{interfaces}->[1]->{classpath};
        my $expected = 'java.io.Serializable';
        print("RES=interface 2=$result.\n") if $debug;
        print("EXP=$expected.\n")           if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test interface 3
        my $result   = $classData->{interfaces}->[2]->{name};
        my $expected = 'Collection<String>';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc

=pod
		my $result = $classData->{javadocStub};
		my $expected = '%VISDOC_STUB_JAVADOC_COMMENT_1%';
		print("RES=$result.\n")     if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
=cut

    }
}

=pod

=cut

sub test_memberpattern_as3 {
    my ($this) = @_;

    my $tmp_parser = VisDoc::ParserAS3->new();
    my $pattern    = VisDoc::StringUtils::stripCommentsFromRegex(
        $tmp_parser->{PATTERN_METHOD_WITH_JAVADOC} );

    my $text = '%VISDOC_STUB_JAVADOC_COMMENT_1%
	private override (undefined) function AllTags () : void {}
	
	%VISDOC_STUB_JAVADOC_COMMENT_2%
	protected function method_B (inValue:Number) : Boolean  {}
	
	%VISDOC_STUB_JAVADOC_COMMENT_3%
	final public function get selectedIndex():Number {}
	
	%VISDOC_STUB_JAVADOC_COMMENT_4%
	function get method_B (inValue:Number) : Boolean;';

    my @matches = ();
    local $_ = $text;
    while (/$pattern/gosx) {
        push(
            @matches,
            {
                javadoc    => $1,
                metadata   => $2,
                access     => $3,
                name       => $6,
                parameters => $9,
                return     => $10,
            }
        );
    }

    # method 1
    {

        # test method 1, javadoc
        my $result   = $matches[0]->{javadoc};
        my $expected = '%VISDOC_STUB_JAVADOC_COMMENT_1%';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 1, access
        my $result   = $matches[0]->{access};
        my $expected = 'private override (undefined)';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 1, name
        my $result   = $matches[0]->{name};
        my $expected = 'AllTags';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 1, return
        my $result   = $matches[0]->{return};
        my $expected = 'void';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # method 2
    {

        # test method 2, javadoc
        my $result   = $matches[1]->{javadoc};
        my $expected = '%VISDOC_STUB_JAVADOC_COMMENT_2%';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 2, access
        my $result   = $matches[1]->{access};
        my $expected = 'protected ';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 2, name
        my $result   = $matches[1]->{name};
        my $expected = 'method_B';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 2, parameters
        my $result   = $matches[1]->{parameters};
        my $expected = 'inValue:Number';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 2, return
        my $result   = $matches[1]->{return};
        my $expected = 'Boolean';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # method 4
    {

        # test method 4, javadoc
        my $result   = $matches[3]->{javadoc};
        my $expected = '%VISDOC_STUB_JAVADOC_COMMENT_4%';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 4, access
        my $result   = $matches[3]->{access};
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 4, name
        my $result   = $matches[3]->{name};
        my $expected = 'get method_B';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 4, parameters
        my $result   = $matches[3]->{parameters};
        my $expected = 'inValue:Number';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 4, return
        my $result   = $matches[3]->{return};
        my $expected = 'Boolean';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_parseMethods_as2 {
    my ($this) = @_;

    my $text = 'class Asd {
	
	public function get count () : Number {}
	public function set count (inCount:Number) : void {}
	
	var __some__;
	
	var bgcolour:Number = 0xCCCC99;

	/**
	constructor javadoc
	*/
	function Asd () 
	{}

	public static function method_B (inKey:String = ",.", inValue:Number) : Boolean 
	{}
	
	public function method_BB (inValue:Number) : Boolean 
	{}

	public function onData () : Void
	{}
	
	%VISDOC_STUB_JAVADOC_COMMENT_2%
	public function interfaceMethod (inValue:Number) : Void {}
	
	%VISDOC_STUB_JAVADOC_COMMENT_3%
	public static function send (inMessage:String) : Void
	{}

	[Event("resizeVideo")]
	[Collection(name="name", variable="varname", collectionClass="config/OpenSpace.xml", collectionItem="coll-item-classname", identifier="string")]
	[InspectableList("fps", "initCuePointNames", "aspectRatio")]
	function get selectedIndex(... rest:Array):Number
	{
		return getSelectedIndex();
	}
}';

    my $fileData  = VisDoc::parseText( $text, 'as2' );
    my $classData = $fileData->{packages}->[0]->{classes}->[0];
    my $methods   = $classData->{methods};

    #use Data::Dumper;
    #print("methods=" . Dumper($methods));

    {

        # test name
        my $result   = $methods->[0]->{name};
        my $expected = 'Asd';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc
        my $result   = $methods->[0]->{javadoc}->getDescription;
        my $expected = 'constructor javadoc';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # method 2
    {

        # test access
        my $access   = $methods->[2]->{access};
        my $result   = join( ",", @{$access} );
        my $expected = 'public';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # method 3
    {

        # test access
        my $access   = $methods->[1]->{access};
        my $result   = join( ",", @{$access} );
        my $expected = 'public,static';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test parameters 0
        my $parameters = $methods->[1]->{parameters};
        my $param      = $parameters->[0];
        my $name       = $param->{name};
        my $dataType   = $param->{dataType};
        my $value      = $param->{value};
        my $result     = "$name:$dataType=$value";
        my $expected   = 'inKey:String=",."';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test parameters 1
        my $parameters = $methods->[1]->{parameters};
        my $param      = $parameters->[1];
        my $name       = $param->{name};
        my $dataType   = $param->{dataType};
        my $result     = "$name:$dataType";
        my $expected   = 'inValue:Number';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test return
        my $result   = $methods->[1]->{returnType};
        my $expected = 'Boolean';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # method 4
    {

        # test name
        my $result   = $methods->[4]->{name};
        my $expected = 'interfaceMethod';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test parameters
        my $parameters = $methods->[4]->{parameters};
        my $param      = $parameters->[0];
        my $name       = $param->{name};
        my $result     = $name;
        my $expected   = 'inValue';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_parseMethods_as3 {
    my ($this) = @_;

    my $text = 'class Z {
	
	public function get count () : Number {}
	public function set count (inCount:Number) : void {}
	
	var __some__;
	
	var bgcolour:Number = 0xCCCC99;

	/**
	constructor javadoc
	*/
	function Z () 
	{}

	override(false) public function method_B (inKey:String = ",.", inValue:Number) : Boolean 
	{}
	
	public override(true) function method_BB (inValue:Number) : Boolean 
	{}

	public function onData () : Void
	{}
	
	%VISDOC_STUB_JAVADOC_COMMENT_2%
	public function interfaceMethod (_some_weird_type_) : Void {}
	
	%VISDOC_STUB_JAVADOC_COMMENT_3%
	public static function send (inMessage:String) : Void
	{}

	[Event("resizeVideo")]
	[Collection(name="name", variable="varname", collectionClass="config/OpenSpace.xml", collectionItem="coll-item-classname", identifier="string")]
	[InspectableList("fps", "initCuePointNames", "aspectRatio")]
	function get selectedIndex(... rest:Array):Number
	{
		return getSelectedIndex();
	}
}';

    my $fileData  = VisDoc::parseText( $text, 'as3' );
    my $classData = $fileData->{packages}->[0]->{classes}->[0];
    my $methods   = $classData->{methods};

    #use Data::Dumper;
    #print("methods=" . Dumper($methods));

    {

        # test name
        my $result   = $methods->[0]->{name};
        my $expected = 'Z';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc
        my $result   = $methods->[0]->{javadoc}->getDescription;
        my $expected = 'constructor javadoc';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # method 3
    {

        # test access
        my $access   = $methods->[1]->{access};
        my $result   = join( ",", @{$access} );
        my $expected = 'override(false),public';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test override
        my $member   = $methods->[1];
        my $result   = $member->overrides();
        my $expected = 0;
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test parameters
        my $parameters = $methods->[1]->{parameters};
        my $param      = $parameters->[0];
        my $name       = $param->{name};
        my $dataType   = $param->{dataType};
        my $value      = $param->{value};
        my $result     = "$name:$dataType=$value";
        my $expected   = 'inKey:String=",."';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test return
        my $result   = $methods->[1]->{returnType};
        my $expected = 'Boolean';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # method 2
    {

        # test access
        my $access   = $methods->[2]->{access};
        my $result   = join( ",", @{$access} );
        my $expected = 'public,override(true)';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    # method 4
    {

        # test name
        my $result   = $methods->[4]->{name};
        my $expected = 'interfaceMethod';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test parameters
        my $parameters = $methods->[4]->{parameters};
        my $param      = $parameters->[0];
        my $name       = $param->{name};
        my $result     = $name;
        my $expected   = '_some_weird_type_';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_parseProperties_as2 {
    my ($this) = @_;

    my $text = 'class AllTags {
	
	/**
	Count property
	*/
	public function get count () : Number {}

	/**
	Count property
	*/
	public function set count (inCount:Number) : void {}
	
	["Event"("resizeVideo")]
[Collection(name="name", variable="varname", collectionClass="config/OpenSpace.xml", collectionItem="coll-item-classname", identifier="string")]
[InspectableList("fps", "initCuePointNames", "aspectRatio")]
	/*2*/ public static var CLICK:String = "click";

	/**
	counter
	*/
	public var counter:Number
	
	/**
	tmp
	*/
	private var __some__
	
	var customItem:CustomClass = new CustomClass()
	
	var someInt:Number = 0

	var numArray:Array = ["zero", "one", "two"]
	
	var i:Number
	i = 20

	/**
	Num vars.
	*/
	private var chimpansee:Number = 10, elephant:Number = 20, tiger:Number = 30
	
	var a1:Number, b1:Number, c1:Number; /**< more num vars */

	var nocolon:String = \'hi\'

	var bgcolour:Number = 0xCCCC99

	public static var DEBUG_LEVEL:Object = {
		level:0,
		string:"Debug",
		color:"#0000CC"
	}	/**< Typecode for debugging messages.		*/
	
	public static var INFO_LEVEL:Object = {
		level:1,
		string:"Info",
		color:"#550088"
	}
	
	public static var NONE:Number = (1<<0); /**< The enumerator does nothing. */
	
	[Event("resizeVideo")]
	[Collection(name="name", variable="varname", collectionClass="config/OpenSpace.xml", collectionItem="coll-item-classname", identifier="string")]
	[InspectableList("fps", "initCuePointNames", "aspectRatio")]
	function get selectedIndex(... rest:Array):Number
	{
		return getSelectedIndex();
	}
}';

    my $fileParser = VisDoc::FileParser->new();
    my $fileData   = $fileParser->parseText($text);
    my $classData  = $fileData->{packages}->[0]->{classes}->[0];
    my $properties = $classData->{properties};

    #use Data::Dumper;
    #print("properties=" . Dumper($properties));

    # property 1
    {

        # test name
        my $result   = $properties->[1]->{name};
        my $expected = 'CLICK';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test access 1
        my $result   = $properties->[1]->{access}->[0];
        my $expected = 'public';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test access 2
        my $result   = $properties->[1]->{access}->[1];
        my $expected = 'static';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test dataType
        my $result   = $properties->[1]->{dataType};
        my $expected = 'String';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test value
        my $result   = $properties->[1]->{value};
        my $expected = '"click"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test metadata name
        my $metadataList = $properties->[1]->{metadata};

        # item 0
        my $metadataItem0 = $metadataList->[0];
        my $result        = $metadataItem0->{name};
        my $expected      = '"Event"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test metadata: item 0: value
        my $metadataList = $properties->[1]->{metadata};

        # item 0
        my $metadataItem0 = $metadataList->[0];
        my $listOfHashes  = $metadataItem0->{items};
        my $contentHash0  = $listOfHashes->[0];
        my $result        = $contentHash0->{'NO_KEY'};
        my $expected      = '"resizeVideo"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test access 'private'
        my $result   = $properties->[3]->{access}->[0];
        my $expected = 'private';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test multiple vars on one line: name
        my $result   = $properties->[9]->{name};
        my $expected = 'elephant';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test multiple vars on one line: javadoc
        my $result   = $properties->[9]->{javadoc}->getDescription();
        my $expected = 'Num vars.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test multiple vars on one line: name (2)
        my $result   = $properties->[13]->{name};
        my $expected = 'c1';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test multiple vars on one line: javadoc side
        my $result   = $properties->[13]->{javadoc}->getDescription();
        my $expected = 'more num vars';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    {

        # test side javadoc
        my $result   = $properties->[16]->{javadoc}->getDescription();
        my $expected = 'Typecode for debugging messages.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    {

        # test metadata: item 2: name
        my $metadataList = $properties->[1]->{metadata};

        # item 0
        my $metadataItem0 = $metadataList->[0];
        my $result        = $metadataItem0->{name};
        my $expected      = '"Event"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test metadata: item 2: value
        my $metadataList = $properties->[1]->{metadata};

        # item 0
        my $metadataItem0 = $metadataList->[0];
        my $listOfHashes  = $metadataItem0->{items};
        my $contentHash0  = $listOfHashes->[0];
        my $result        = $contentHash0->{'NO_KEY'};
        my $expected      = '"resizeVideo"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test metadata: item 2: value
        my $metadataList = $properties->[1]->{metadata};

        # item 0
        my $metadataItem1 = $metadataList->[1];
        my $listOfHashes  = $metadataItem1->{items};
        my $contentHash2  = $listOfHashes->[2];
        my $key           = ( keys %$contentHash2 )[0];
        {
            my $result   = $key;
            my $expected = 'collectionClass';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
        {
            my $stubKey  = $contentHash2->{$key};
            my $expected = '"config/OpenSpace.xml"';
            my $result   = $fileParser->getContents($stubKey);
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }
    }
    {

        # test getter/setter method
        my $result   = $properties->[19]->{name};
        my $expected = 'selectedIndex';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_parseProperties__getsetonly_as2 {
    my ($this) = @_;

    my $text = 'class AAA {
	
	public function get count () : Number {}
	public function set count (inCount:Number) : void {}

}';

    my $fileParser = VisDoc::FileParser->new();
    my $fileData   = $fileParser->parseText($text);
    my $classData  = $fileData->{packages}->[0]->{classes}->[0];
    my $properties = $classData->{properties};

    #use Data::Dumper;
    #print("properties=" . Dumper($properties));

    {

        # test name
        my $result   = $properties->[0]->{name};
        my $expected = 'count';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test property 2 (does not exist)
        my $result = $properties->[1];
        $this->assert_null($result);
    }
    {

        # test dataType
        my $result   = $properties->[0]->{dataType};
        my $expected = 'Number';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test isAccessPublic
        my $result   = $properties->[0]->{isAccessPublic};
        my $expected = 1;
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_parseProperties_as3 {
    my ($this) = @_;

    my $text = 'class Def {
	
	/**
	Count property
	*/
	/*0*/ public function get count () : Number {}

	/**
	Count property
	*/
	/*1*/ public function set count (inCount:Number) : void {}
	
	["Event"("resizeVideo")]
	[Collection(name="name", variable="varname", collectionClass="config/OpenSpace.xml", collectionItem="coll-item-classname", identifier="string")]
	[InspectableList("fps", "initCuePointNames", "aspectRatio")]
	/*2*/ public static const CLICK:String = "click";

	/**
	counter
	*/
	/*3*/ public var counter:Number
	
	/**
	tmp
	*/
	/*4*/ protected var __some__
	
	/*5*/ var customItem:CustomClass = new CustomClass()
	
	/*6*/ var someInt:int = new int(3)

	/*7*/ var numArray:Array = ["zero", "one", "two"]
	
	/*8*/ var i:int
	i = 20

	/**
	Num vars.
	*/
	/*9,10,11*/ private var chimpansee:int = 10, camel:int = 20, tiger:int = 30
	
	/*12,13,14*/ var a1:int, b1:int, c1:int; /**< more num vars */

	/*15*/ var nocolon:String = \'hi\'

	/*16*/ var bgcolour:Number = 0xCCCC99

	/*17*/ public static var DEBUG_LEVEL:Object = {
		level:0,
		string:"Debug",
		color:"#0000CC"
	}	/**< Typecode for debugging messages.		*/
	
	/*18*/ public static var INFO_LEVEL:Object = {
		level:1,
		string:"Info",
		color:"#550088"
	}
	
	/*19*/ public static const NONE:uint = (1<<0); /**< The enumerator does nothing. */
	
	[Event("resizeVideo")]
	[Collection(name="name", variable="varname", collectionClass="config/OpenSpace.xml", collectionItem="coll-item-classname", identifier="string")]
	[InspectableList("fps", "initCuePointNames", "aspectRatio")]
	/*20*/ function get selectedIndex(... rest:Array):Number
	{
		return getSelectedIndex();
	}
}';

    my $fileData   = VisDoc::parseText( $text, 'as3' );
    my $classData  = $fileData->{packages}->[0]->{classes}->[0];
    my $properties = $classData->{properties};

    #use Data::Dumper;
    #print("properties=" . Dumper($properties));

    # property 2
    {

        # test name
        my $result   = $properties->[1]->{name};
        my $expected = 'CLICK';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test access 2->0
        my $result   = $properties->[1]->{access}->[0];
        my $expected = 'public';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test access 2->1
        my $result   = $properties->[1]->{access}->[1];
        my $expected = 'static';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test type
        my $result =
          VisDoc::PropertyData::typeString( $properties->[1]->{type} );
        my $expected = 'CONST';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test dataType
        my $result   = $properties->[1]->{dataType};
        my $expected = 'String';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test value
        my $result   = $properties->[1]->{value};
        my $expected = '"click"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test metadata name
        my $metadataList = $properties->[1]->{metadata};

        # item 0
        my $metadataItem0 = $metadataList->[0];
        my $result        = $metadataItem0->{name};
        my $expected      = '"Event"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test metadata: item 0: value
        my $metadataList = $properties->[1]->{metadata};

        # item 0
        my $metadataItem0 = $metadataList->[0];
        my $listOfHashes  = $metadataItem0->{items};
        my $contentHash0  = $listOfHashes->[0];
        my $result        = $contentHash0->{'NO_KEY'};
        my $expected      = '"resizeVideo"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test access 'protected'
        my $result   = $properties->[3]->{access}->[0];
        my $expected = 'protected';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test multiple vars on one line: name
        my $result   = $properties->[9]->{name};
        my $expected = 'camel';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test multiple vars on one line: javadoc
        my $result   = $properties->[9]->{javadoc}->getDescription();
        my $expected = 'Num vars.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test multiple vars on one line: name (2)
        my $result   = $properties->[13]->{name};
        my $expected = 'c1';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test multiple vars on one line: javadoc side
        my $result   = $properties->[13]->{javadoc}->getDescription();
        my $expected = 'more num vars';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    {

        # test side javadoc
        my $result   = $properties->[16]->{javadoc}->getDescription();
        my $expected = 'Typecode for debugging messages.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    {

        # test metadata: item 2: name
        my $metadataList = $properties->[1]->{metadata};

        # item 0
        my $metadataItem0 = $metadataList->[0];
        my $result        = $metadataItem0->{name};
        my $expected      = '"Event"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test metadata: item 2: value
        my $metadataList = $properties->[1]->{metadata};

        # item 0
        my $metadataItem0 = $metadataList->[0];
        my $listOfHashes  = $metadataItem0->{items};
        my $contentHash0  = $listOfHashes->[0];
        my $result        = $contentHash0->{'NO_KEY'};
        my $expected      = '"resizeVideo"';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test metadata: item 2: value
        my $metadataList = $properties->[1]->{metadata};

        # item 0
        my $metadataItem1 = $metadataList->[1];
        my $listOfHashes  = $metadataItem1->{items};
        my $contentHash2  = $listOfHashes->[2];
        my $key           = ( keys %$contentHash2 )[0];
        {
            my $result   = $key;
            my $expected = 'collectionClass';
            print("RES=$result.\n")   if $debug;
            print("EXP=$expected.\n") if $debug;
            $this->assert( $result eq $expected );
        }

=pod
		{
			my $stubKey = $contentHash2->{$key};
			my $expected = '"config/OpenSpace.xml"';
			my $result = $fileParser->getContents($stubKey);
			print("RES=$result.\n")     if $debug;
			print("EXP=$expected.\n") if $debug;
			$this->assert( $result eq $expected );
		}
=cut

    }
    {

        # test getter/setter method
        my $result   = $properties->[19]->{name};
        my $expected = 'selectedIndex';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_parseProperties_as3_array {
    my ($this) = @_;

    my $text = "
package {
	class Def {

		public static var AUDIO_EXTENSIONS:Array = new Array('f4a', 'f4b', 'mp3'), VIDEO_EXTENSIONS:Array = new Array('mov', 'wma', 'mpg'); /**< The default list of audio file extensions. */

		/**
		Num vars.
		*/
		private var chimpansee:Number = 10, elephant:Number = 20, tiger:Number = 30;
	}
}";

	my $fileData   = VisDoc::parseText( $text, 'as3' );
    my $classData  = $fileData->{packages}->[0]->{classes}->[0];
    my $properties = $classData->{properties};

    #use Data::Dumper;
    #print("properties=" . Dumper($properties));

	{
		# property 0: name
		my $result   = $properties->[0]->{name};
		my $expected = 'AUDIO_EXTENSIONS';
		print("RES=$result.\n")   if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
	{
		# property 0: value
		my $result   = $properties->[0]->{value};
		my $expected = "new Array('f4a', 'f4b', 'mp3')";
		print("RES=$result.\n")   if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
	{
		# property 1: name
		my $result   = $properties->[1]->{name};
		my $expected = 'VIDEO_EXTENSIONS';
		print("RES=$result.\n")   if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
	{
		# property 1: value
		my $result   = $properties->[1]->{value};
		my $expected = "new Array('mov', 'wma', 'mpg')";
		print("RES=$result.\n")   if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
	{
		# property 2: name
		my $result   = $properties->[2]->{name};
		my $expected = 'chimpansee';
		print("RES=$result.\n")   if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
	{
		# property 3: name
		my $result   = $properties->[3]->{name};
		my $expected = 'elephant';
		print("RES=$result.\n")   if $debug;
		print("EXP=$expected.\n") if $debug;
		$this->assert( $result eq $expected );
	}
	
}

=pod

=cut

sub test_parseClasses_java_short {
    my ($this) = @_;

    my $text = 'package points; 
class PointVec { Point[] vec; }';

    my $fileData   = VisDoc::parseText( $text, 'java' );
    my $classData  = $fileData->{packages}->[0]->{classes}->[0];
    my $properties = $classData->{properties};

    #use Data::Dumper;
    #print("classData=" . Dumper($classData));

    {

        # test package name
        my $result   = $fileData->{packages}->[0]->{name};
        my $expected = 'points';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class name
        my $result   = $classData->{name};
        my $expected = 'PointVec';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test property name
        my $result   = $properties->[0]->{name};
        my $expected = 'vec';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test property type
        my $result   = $properties->[0]->{dataType};
        my $expected = 'Point[]';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_parseClasses_java_interface {
    my ($this) = @_;

    my $text = 'package it.gotoandplay.smartfoxclient;

/**
 * ISFSEventListener must be implemented by all classes that listen for SmarFoxSever events.
 * 
 * @see it.gotoandplay.smartfoxclient.SmartFoxClient
 * @see it.gotoandplay.smartfoxclient.SFSEvent
 * @see SFSEventDispatcher
 * 
 * @version 1.0.0
 * 
 * @author The gotoAndPlay() Team<br>
 *         <a href="http://www.smartfoxserver.com">http://www.smartfoxserver.com</a><br>
 *         <a href="http://www.gotoandplay.it">http://www.gotoandplay.it</a><br>
 */
public interface ISFSEventListener
{
    /**
     * Handles SmartFoxServer event.
     * 
     * @param event the event that is fired.
     */
    void handleEvent(SFSEvent event, String[] args);
    
    void run() throws E;
    
    public abstract char get() throws BufferError;
    
    boolean addAll(Collection<? extends E> c);
    
    void printCollection(Collection<?> c);
}
';

    my $fileData  = VisDoc::parseText( $text, 'java' );
    my $classData = $fileData->{packages}->[0]->{classes}->[0];
    my $methods   = $classData->{methods};

    #use Data::Dumper;
    #print("classData=" . Dumper($classData));

    {

        # test class name
        my $result   = $classData->{name};
        my $expected = 'ISFSEventListener';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class type (interface)
        my $result   = $classData->{type};
        my $expected = $VisDoc::ClassData::TYPE->{'INTERFACE'};
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 0: name
        my $result   = $methods->[0]->{name};
        my $expected = 'handleEvent';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 0: parameters 0
        my $parameterData = $methods->[0]->{parameters}->[0];
        my $name          = $parameterData->{name};
        my $dataType      = $parameterData->{dataType};
        my $value         = $parameterData->{value} || '';
        my $result        = "$dataType $name=$value";
        my $expected      = 'SFSEvent event=';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 1: name
        my $result   = $methods->[1]->{name};
        my $expected = 'run';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 1: returnType
        my $result   = $methods->[1]->{returnType};
        my $expected = 'void';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 1: exceptionType
        my $result   = $methods->[1]->{exceptionType};
        my $expected = 'E';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method 3: parameters 0
        my $parameterData = $methods->[3]->{parameters}->[0];
        my $name          = $parameterData->{name};
        my $dataType      = $parameterData->{dataType};
        my $value         = $parameterData->{value} || '';
        my $result        = "$dataType $name=$value";
        my $expected      = 'Collection<? extends E> c=';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_URI_as2_class {
    my ($this) = @_;

    my $text = '	
	class SpeakingPets  {}';

    my $fileParser = VisDoc::FileParser->new();
    my $fileData   = $fileParser->parseText( $text, 'as2' );
    my $classes    = $fileData->{packages}->[0]->{classes};
    my $classData  = $classes->[0];

    my $result   = $classData->getUri();
    my $expected = 'SpeakingPets';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_URI_as2_class_with_classpath {
    my ($this) = @_;

    my $text = '	
	class com.visiblearea.SpeakingPets extends Sprite implements IAnimal, ISprite {
		//
	}';

    my $fileParser = VisDoc::FileParser->new();
    my $fileData   = $fileParser->parseText( $text, 'as2' );
    my $classes    = $fileData->{packages}->[0]->{classes};
    my $classData  = $classes->[0];

    my $result   = $classData->getUri();
    my $expected = 'com_visiblearea_SpeakingPets';
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_URI_as3 {
    my ($this) = @_;

    my $text = '/*
this is not
class TraverseArrayOptions {
*/
package org.asaplibrary.data.array /*ehm*/{

	/**
	Class
	*/
	public class TraverseArrayOptions {
	}
}';

    my $fileData = VisDoc::parseText( $text, 'as3' );

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test package
        my $packageData = $fileData->{packages}->[0];

        my $result   = $packageData->getUri();
        my $expected = 'package_org_asaplibrary_data_array';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class
        my $classData = $fileData->{packages}->[0]->{classes}->[0];

        my $result   = $classData->getUri();
        my $expected = 'org_asaplibrary_data_array_TraverseArrayOptions';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_URI_java {
    my ($this) = @_;

    my $text = 'package treemap;

import java.util.Enumeration;

public interface TMNode {

    public Enumeration children();
}';

    my $fileData = VisDoc::parseText( $text, 'java' );

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test package
        my $packageData = $fileData->{packages}->[0];

        my $result   = $packageData->getUri();
        my $expected = 'package_treemap';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class
        my $classData = $fileData->{packages}->[0]->{classes}->[0];

        my $result   = $classData->getUri();
        my $expected = 'treemap_TMNode';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_getDescriptionParts_simple {
    my ($this) = @_;

    my $text = '/**
Blo
*/
class A {}
';

    my $fileData = VisDoc::parseText( $text, 'as2' );
    my $description =
      $fileData->{packages}->[0]->{classes}->[0]->{javadoc}->getDescription();
    my ( $beforeFirstLineTag, $summaryLine, $rest ) =
      $fileData->getDescriptionParts($description);

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test tag before summary line
        my $result   = $beforeFirstLineTag;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test summary line
        my $result   = $summaryLine;
        my $expected = 'Blo';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test rest
        my $result   = $rest;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_getDescriptionParts_simple2 {
    my ($this) = @_;

    my $text = '/**
Blo...
*/
class A {}
';

    my $fileData = VisDoc::parseText( $text, 'as2' );
    my $description =
      $fileData->{packages}->[0]->{classes}->[0]->{javadoc}->getDescription();
    my ( $beforeFirstLineTag, $summaryLine, $rest ) =
      $fileData->getDescriptionParts($description);

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test tag before summary line
        my $result   = $beforeFirstLineTag;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test summary line
        my $result   = $summaryLine;
        my $expected = 'Blo...';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test rest
        my $result   = $rest;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_getDescriptionParts_empty {
    my ($this) = @_;

    my $text = '/**
*/
class A {}
';

    my $fileData = VisDoc::parseText( $text, 'as2' );
    my $description =
      $fileData->{packages}->[0]->{classes}->[0]->{javadoc}->getDescription();
    my ( $beforeFirstLineTag, $summaryLine, $rest ) =
      $fileData->getDescriptionParts($description);

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test tag before summary line
        my $result   = $beforeFirstLineTag;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test summary line
        my $result   = $summaryLine;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test rest
        my $result   = $rest;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_getDescriptionParts_1 {
    my ($this) = @_;

    my $text = '/**
Bla. blo <pre>xyz</pre> all the rest.
*/
class A {}
';

    my $fileData = VisDoc::parseText( $text, 'as2' );
    my $description =
      $fileData->{packages}->[0]->{classes}->[0]->{javadoc}->getDescription();
    my ( $beforeFirstLineTag, $summaryLine, $rest ) =
      $fileData->getDescriptionParts($description);

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test tag before summary line
        my $result   = $beforeFirstLineTag;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test summary line
        my $result   = $summaryLine;
        my $expected = 'Bla. ';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test rest
        my $result   = $rest;
        my $expected = 'blo <code>xyz</code> all the rest.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_getDescriptionParts_2 {
    my ($this) = @_;

    my $text = '/**
<code>xyz... something else. Line two. </code> All the rest.
*/
class A {}
';

    my $fileData = VisDoc::parseText( $text, 'as2' );
    my $description =
      $fileData->{packages}->[0]->{classes}->[0]->{javadoc}->getDescription();
    my ( $beforeFirstLineTag, $summaryLine, $rest ) =
      $fileData->getDescriptionParts($description);

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test tag before summary line
        my $result   = $beforeFirstLineTag;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test summary line
        my $result   = $summaryLine;
        my $expected = '<code>xyz... ';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test rest
        my $result = $rest;
        my $expected =
'something <span class="codeKeyword">else</span>. Line two.</code> All the rest.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_getDescriptionParts_3 {
    my ($this) = @_;

    my $text = '/**
<p>xyz
<pre>
something else
</pre> all the rest.</p>
*/
class A {}
';

    my $fileData = VisDoc::parseText( $text, 'as2' );
    my $description =
      $fileData->{packages}->[0]->{classes}->[0]->{javadoc}->getDescription();
    my ( $beforeFirstLineTag, $summaryLine, $rest ) =
      $fileData->getDescriptionParts($description);

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test tag before summary line
        my $result   = $beforeFirstLineTag;
        my $expected = '<p>';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test summary line
        my $result   = $summaryLine;
        my $expected = 'xyz';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test rest
        my $result   = $rest;
        my $expected = '
<code>something <span class="codeKeyword">else</span></code> all the rest.</p>';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

Test email string.

=cut

sub test_getDescriptionParts_4 {
    my ($this) = @_;

    my $text = '/**
first.last@comp.com <b>yo!</b>
*/
class A {}
';

    my $fileData = VisDoc::parseText( $text, 'as2' );
    my $description =
      $fileData->{packages}->[0]->{classes}->[0]->{javadoc}->getDescription();
    my ( $beforeFirstLineTag, $summaryLine, $rest ) =
      $fileData->getDescriptionParts($description);

    #use Data::Dumper;
    #print("fileData=" . Dumper($fileData));

    {

        # test tag before summary line
        my $result   = $beforeFirstLineTag;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test summary line
        my $result   = $summaryLine;
        my $expected = 'first.last@comp.com <b>yo!</b>';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test rest
        my $result   = $rest;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_getDescriptionParts_5 {
    my ($this) = @_;

    my $text = '/**
Testing @see references, see {@link #aFunction a number of @see examples}.
{@code test code text}
*/
class ABC {
	public function aFunction () {}
}
';

    my $fileData = VisDoc::parseText( $text, 'as2' );
    my $description =
      $fileData->{packages}->[0]->{classes}->[0]->{javadoc}->getDescription();
    my ( $beforeFirstLineTag, $summaryLine, $rest ) =
      $fileData->getDescriptionParts($description);

    {

        # test tag before summary line
        my $result   = $beforeFirstLineTag;
        my $expected = '';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test summary line
        my $result = $summaryLine;
        my $expected =
'Testing @see references, see <a href="ABC.html#aFunction">a number of @see examples</a>.';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test rest
        my $result   = $rest;
        my $expected = '
<code>test code text</code>';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

1;
