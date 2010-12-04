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
package org.asaplibrary.data.array /*ehm*/{

	/**
	Array traverse options used by TraverseArrayEnumerator. The state options use bitwise operators, see ButtonStates for an example.
	*/
	public class TraverseArrayOptions {
	
		public static const NONE:uint = 0; /**< The enumerator does nothing. */
		public static const LOOP:uint = 1; /**< The enumerator loops past the last item. */
		
	}
}
