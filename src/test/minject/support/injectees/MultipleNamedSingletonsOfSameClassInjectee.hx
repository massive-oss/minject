// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Interface1;
import minject.support.types.Interface2;

class MultipleNamedSingletonsOfSameClassInjectee
{
	public static var NAME1 = 'name1';
	public static var NAME2 = 'name2';

	@inject
	public var property1:Interface1;

	@inject
	public var property2:Interface2;

	@inject('name1')
	public var namedProperty1:Interface1;

	@inject('name2')
	public var namedProperty2:Interface2;

	public function new(){}
}
