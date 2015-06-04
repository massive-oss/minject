// See the file "LICENSE" for the full license governing this code

package minject.support.injectees.childinjectors;

import minject.Injector;

class NestedInjectorInjectee
{
	public function new(){}

	@inject
	public var injector: Injector;
	public var nestedInjectee: NestedNestedInjectorInjectee;

	@post
	public function createAnotherChildInjector()
	{
		nestedInjectee = injector.instantiate(NestedNestedInjectorInjectee);
	}
}
