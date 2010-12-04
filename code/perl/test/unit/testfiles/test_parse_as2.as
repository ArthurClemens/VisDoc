/**
* FlickrBlogs
* last update 08/25/2004

* @version	1.0
* @author	Fabricio Zuardi
*/;
class com.zuardi.flickr.FlickrBlogs
{
	
	/**
	Some comment.
	*/
	function FlickrBlogs()
	{
		var pets:Array = [new Cat(), new Dog()]; /**< Instantiate empty list of basic pets. */
		for each (var pet:* in pets)
		{
			command(pet);
		}
	}
};
