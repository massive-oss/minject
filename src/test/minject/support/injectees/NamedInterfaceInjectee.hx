// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Interface1;

class NamedInterfaceInjectee
{
	public static var NAME = 'name';

	@inject('name')
	public var property:Interface1;

	public function new(){}
}
