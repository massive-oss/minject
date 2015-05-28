// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Interface1;

class TwoNamedInterfaceFieldsInjectee
{
	public static var NAME1 = 'name1';
	public static var NAME2 = 'name2';

	@inject('name1')
	public var property1:Interface1;

	@inject('name2')
	public var property2:Interface1;

	public function new(){}
}
