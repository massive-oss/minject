// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class NamedClassInjectee
{
	public static var NAME = 'name';

	@inject('name')
	public var property:Class1;

	public function new(){}
}
