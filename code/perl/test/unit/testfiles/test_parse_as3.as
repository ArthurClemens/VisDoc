/*
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
		var nocolon:String = \'hi\'

		var bgcolour:Number = 0xCCCC99;

		public static var DEBUG_LEVEL:Object = {
			level:0,
			string:"Debug",
			color:"#0000CC"
		};	/**< Typecode for debugging messages.		*/
		
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
}