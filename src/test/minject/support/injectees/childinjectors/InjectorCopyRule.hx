// See the file "LICENSE" for the full license governing this code


package minject.support.injectees.childinjectors;

import minject.InjectorMapping;
import minject.Injector;

class InjectorCopyRule extends InjectorMapping<Injector>
{
	public function new()
	{
		super('minject.Injector', '');
	}

	public override function getValue(injector:Injector):Injector
	{
		return injector.createChildInjector();
	}
}
