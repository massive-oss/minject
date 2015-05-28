// See the file "LICENSE" for the full license governing this code

package minject.support.injectees.childinjectors;

import minject.Injector;

class NestedNestedInjectorInjectee
{
	public function new(){}

	@inject
	public var injector:Injector;
}
