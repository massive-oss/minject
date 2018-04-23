// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Interface1;

class RecursiveInterfaceInjectee implements Interface1
{
	@inject
	public var interfaceInjectee:InterfaceInjectee;

	public function new(){}
}
