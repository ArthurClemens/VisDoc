
/**
* Testing including a member from another file.
*/

package {
	class MainClass {
		
		public function MainClass ()
		{
		
		}
		
		include "../included_method.as"
		include "included_method2.as"
	}
}