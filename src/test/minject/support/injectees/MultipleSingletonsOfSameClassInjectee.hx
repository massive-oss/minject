// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Interface1;
import minject.support.types.Interface2;

class MultipleSingletonsOfSameClassInjectee
{
	@inject
	public var property1:Interface1;

	@inject
	public var property2:Interface2;

	public function new(){}
}
