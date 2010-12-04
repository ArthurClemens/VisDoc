use strict;
use warnings;
use diagnostics;

package VisDocTests;
use base qw(Test::Unit::TestCase);

use Scalar::Util qw(refaddr);    # for testing object equality
use VisDoc;

my $debug = 0;

sub new {
    my $self = shift()->SUPER::new(@_);

    # your state for fixture here
    return $self;
}

sub set_up {
    my ($this) = @_;

    VisDoc::FileData::initLinkDataRefs();
}

=pod

Tests reading in an arbitrary text file.

=cut

sub test_readFile {
    my ($this) = @_;

    my $here     = Cwd::abs_path . '/testfiles';
    my $path     = "$here/testfile.txt";
    my $result   = VisDoc::readFile($path);
    my $expected = 'testfile
2
3
END OF TESTFILE';

    chomp $expected;
    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );

}

=pod

=cut

sub test_parseText_as2 {
    my ($this) = @_;

    my $text = 'class EventHandlersExample {

	/**
	@sends #onChanged onChanged (when the selection is changed by the program)
	*/
	public function method_A () : Void 
	{
		broadcastMessage("onChanged", changedTextField);
	}
}';
    my @texts;
    push @texts, $text;
    my $fileData  = VisDoc::parseTexts( \@texts );
    my $classData = $fileData->[0]->{packages}->[0]->{classes}->[0];

    #use Data::Dumper;
    #print("classData=" . Dumper($classData));

    {

        # test class name
        my $result   = $classData->{name};
        my $expected = 'EventHandlersExample';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

    {

        # test sends entry
        my $result =
          $classData->{methods}->[0]->{javadoc}->fieldsWithName('sends')->[0]
          ->{label};
        my $expected =
          'onChanged (when the selection is changed by the program)';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }

}

=pod

=cut

sub test_parseText_as3 {
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
// speaking pets in ActionScript 3
/**
Information about this "package".
*/
package blo /*ehm*/
{
	import flash.display.Sprite;

	/**
	* About speaking pets.
	* @use
	* <code>
	* new SpeakingPets();
	* </code>
	* or
	* {@code new SpeakingPets();}
	* @see: SpeakingCat
	* @test
	* still at line test
	*/
	public class SpeakingPets extends Sprite implements Animal
	{
		/**
		Some comment.
		*/
		public function SpeakingPets()
		{
			var pets:Array = [new Cat(), new Dog()]; /**< Instantiate empty list of basic pets. */
			for each (var pet:* in pets)
			{
				command(pet);
			}
		}
	}
}

/**
@author John Doe
@description This class also belongs to package blo.
@param p1 One
@param p2:Two
@param p3 (optional) : Three
*/
class Pet
{
	/**
	Speaks "}"
	@example
	<code>
	speak();
	</code>
	*/
	public function speak():void
	{
	}
}

class Dog extends Pet
{
	public override function speak():void
	{
		trace("woof!");
	}
}

class Cat extends Pet
{
	public override function speak():void
	{
		trace("meow!");
	}
}

/**
command info
*/
// comment
function command(pet:Pet):void
{
	pet.speak();
}';
    my $fileData    = VisDoc::parseText($text);
    my $packageData = $fileData->{packages}->[0];

    #use Data::Dumper;
    #print(Dumper($packageData));

    {

        # test package name
        my $result   = $fileData->{packages}->[0]->{name};
        my $expected = 'blo';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test package javadoc
        my $result   = $fileData->{packages}->[0]->{javadoc}->getDescription();
        my $expected = 'Information about this "package".';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class name
        my $result   = $fileData->{packages}->[0]->{classes}->[0]->{name};
        my $expected = 'SpeakingPets';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method name 0
        my $result =
          $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{name};
        my $expected = 'SpeakingPets';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc comment 0
        my $result =
          $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{javadoc}
          ->getDescription();
        my $expected = 'Some comment.';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_parseFile_as3 {
    my ($this) = @_;

    my $here = Cwd::abs_path . '/testfiles';
    my $path = "$here/test_parse_as3.as";

    my ( $fileData, $fileParser ) = VisDoc::parseFile($path);

    #use Data::Dumper;
    #print(Dumper($fileData));

    {

        # test package name
        my $result   = $fileData->{packages}->[0]->{name};
        my $expected = 'blo';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test package javadoc
        my $result   = $fileData->{packages}->[0]->{javadoc}->getDescription();
        my $expected = 'Information about this "package".';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class name
        my $result   = $fileData->{packages}->[0]->{classes}->[0]->{name};
        my $expected = 'SpeakingPets';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method name 0
        my $result =
          $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{name};
        my $expected = 'SpeakingPets';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc comment 0
        my $result =
          $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{javadoc}
          ->getDescription();
        my $expected = 'Some comment.';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_parseFile_as2 {
    my ($this) = @_;

    my $here = Cwd::abs_path . '/testfiles';
    my $path = "$here/test_parse_as2.as";

    my ( $fileData, $fileParser ) = VisDoc::parseFile($path);

    #use Data::Dumper;
    #print(Dumper($fileData));

    {

        # test package name
        my $result   = $fileData->{packages}->[0]->{name};
        my $expected = 'com.zuardi.flickr';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class name
        my $result   = $fileData->{packages}->[0]->{classes}->[0]->{name};
        my $expected = 'FlickrBlogs';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method name 0
        my $result =
          $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{name};
        my $expected = 'FlickrBlogs';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc comment 0
        my $result =
          $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{javadoc}
          ->getDescription();
        my $expected = 'Some comment.';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

=cut

sub test_parseFile_java {
    my ($this) = @_;

    my $here = Cwd::abs_path . '/testfiles';
    my $path = "$here/test_parse_java.java";

    my ( $fileData, $fileParser ) = VisDoc::parseFile($path);

    #use Data::Dumper;
    #print(Dumper($fileData));

    {

        # test package name
        my $result   = $fileData->{packages}->[0]->{name};
        my $expected = 'treemap';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test package javadoc
        my $result   = $fileData->{packages}->[0]->{javadoc}->getDescription();
        my $expected = 'Information about this package.';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class 0: name
        my $result   = $fileData->{packages}->[0]->{classes}->[0]->{name};
        my $expected = 'TMView';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test inner class
        my $outerClass = $fileData->{packages}->[0]->{classes}->[0];    # TMView

        my $result =
          join( ",", map { $_->{name} } @{ $outerClass->{innerClasses} } );
        my $expected = 'PaintMethod,EmptyPaintMethod,FullPaintMethod';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test enclosingClass
        # which should be the same result as testing for inner class
        my $outerClass = $fileData->{packages}->[0]->{classes}->[0];    # TMView
        my @enclosingClasses;
        foreach my $class ( @{ $fileData->{packages}->[0]->{classes} } ) {
            my $enclosingClass = $class->{enclosingClass};
            if ($enclosingClass) {
                push @enclosingClasses, $class->{name}
                  if ( refaddr($enclosingClass) == refaddr($outerClass) );
            }
        }
        my $result = join( ",", @enclosingClasses );
        my $expected = 'PaintMethod,EmptyPaintMethod,FullPaintMethod';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test method name 0
        my $result =
          $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{name};
        my $expected = 'paint';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc comment 0
        my $result =
          $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{javadoc}
          ->getDescription();
        my $expected = 'Paint method.';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test javadoc param 0
        my $paramField =
          $fileData->{packages}->[0]->{classes}->[0]->{methods}->[0]->{javadoc}
          ->{params}->[0];
        my $name     = $paramField->{name};
        my $value    = $paramField->{value};
        my $result   = "$name=$value";
        my $expected = 'g=the Graphics2D context';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

=pod

Tests merging data of 2 classes (because they have the same package).

=cut

sub test_parseTexts_as3 {
    my ($this) = @_;

    my $text1 = '/*
/**
Information about this "package".
*/
package animals
{
	public class SpeakingPets {
	
		function SpeakingPets () {
			trace("new SpeakingPets");
			howl();
		}
	}
}

function howl () : void {
	trace("woooooooooooo");
}
';

    my $text2 = '/*
/**
More information about this package.
*/
package animals
{
	public class Cat extends SpeakingPets {
	
		function Cat () {
			super();
		}
	}	
}

function growl () : void {}
';

    my @texts = ( $text1, $text2 );
    my $fileData = VisDoc::parseTexts( \@texts, 'as3' );

    my $preferences;
    $preferences->{saveXML} = 1;

    {
        # test package javadoc
        my $result =
          $fileData->[0]->{packages}->[0]->{javadoc}->getDescription();
        my $expected =
'Information about this "package". More information about this package.';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class name 0
        my $result   = $fileData->[0]->{packages}->[0]->{classes}->[0]->{name};
        my $expected = 'SpeakingPets';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test class name 1
        my $result   = $fileData->[0]->{packages}->[0]->{classes}->[1]->{name};
        my $expected = 'Cat';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test function name 0
        my $result = $fileData->[0]->{packages}->[0]->{functions}->[0]->{name};
        my $expected = 'howl';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {

        # test function name 1
        my $result = $fileData->[0]->{packages}->[0]->{functions}->[1]->{name};
        my $expected = 'growl';

        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_generateHtml_as3 {
    my ($this) = @_;

    my $text1 = '/*
/**
Information about this "package".
*/
package animals
{
	public class SpeakingPets {
	
		function SpeakingPets () {
			trace("new SpeakingPets");
			howl();
		}
	}
}

function howl () : void {
	trace("woooooooooooo");
}
';

    my $text2 = '/*
/**
More information about this package.
*/
package animals
{
	public class Cat extends SpeakingPets {
	
		function Cat () {
			super();
		}
	}	
}

public function growl () : void {}
';

    my @texts = ( $text1, $text2 );
    my $fileData = VisDoc::parseTexts( \@texts, 'as3' );

	use VisDoc::Defaults;
    my $preferences = $VisDoc::Defaults::SETTINGS;
    $preferences->{saveXML} = 1;
	$VisDoc::Defaults::FILE_DOCTERMS         = '../../templates/lang/docterms.json';
	$VisDoc::Defaults::FILE_JAVADOCTERMS     = '../../templates/lang/javadocterms.json';
	$VisDoc::Defaults::FILE_JS_TEMPLATE_DIR  = '../../templates/js/';
    $preferences->{saveXML} = 1;
    $preferences->{templateCssDirectory} = '../../templates/css';
    $preferences->{templateJsDirectory} = '../../templates/js';
    $preferences->{templateFreeMarker} = '../../templates/ftl/VisDoc.ftl';

    VisDoc::writeData('testfiles/docs/', $fileData, $preferences);
}

=pod

Test merging of 2 package javadocs, where both javadocs exist.

=cut

sub test_mergeJavadocs_a_and_b {
    my ($this) = @_;

    my $text_a = '/*
/**
Information about this "package".
*/
package a
{
	class A {}
}
';

    my $text_b = '/*
/**
More information about this package.
*/
package a
{
	class B {}
}
';
    my @texts = ( $text_a, $text_b );
    my $fileData = VisDoc::parseTexts( \@texts, 'as3' );

    #use Data::Dumper;
    #print(Dumper($fileData));

    # test package javadoc
    my $result = $fileData->[0]->{packages}->[0]->{javadoc}->getDescription();
    my $expected =
      'Information about this "package". More information about this package.';

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

Test merging of 2 package javadocs, where only javadoc a exists.

=cut

sub test_mergeJavadocs_a {
    my ($this) = @_;

    my $text_a = '/*
/**
Information about this "package".
*/
package a
{
	class A {}
}
';

    my $text_b = '
package a
{
	class B {}
}
';
    my @texts = ( $text_a, $text_b );
    my $fileData = VisDoc::parseTexts( \@texts, 'as3' );

    #use Data::Dumper;
    #print(Dumper($fileData));

    # test package javadoc
    my $result   = $fileData->[0]->{packages}->[0]->{javadoc}->getDescription();
    my $expected = 'Information about this "package".';

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

Test merging of 2 package javadocs, where only javadoc b exists.

=cut

sub test_mergeJavadocs_b {
    my ($this) = @_;

    my $text_a = 'package a
{
	class A {}
}
';

    my $text_b = '/*
/**
More information about this package.
*/
package a
{
	class B {}
}
';
    my @texts = ( $text_a, $text_b );
    my $fileData = VisDoc::parseTexts( \@texts, 'as3' );

    #use Data::Dumper;
    #print(Dumper($fileData));

    # test package javadoc
    my $result   = $fileData->[0]->{packages}->[0]->{javadoc}->getDescription();
    my $expected = 'More information about this package.';

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

1;
