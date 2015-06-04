// See the file "LICENSE" for the full license governing this code

package minject.provider;

import minject.Injector;

class ClassProvider<T> implements DependencyProvider<T>
{
	var type:Class<T>;

	public function new(type:Class<T>)
	{
		this.type = type;
	}

	public function getValue(injector:Injector):T
	{
		return injector._instantiate(type);
	}

	#if debug
	public function toString():String
	{
		return 'class ' + Type.getClassName(type);
	}
	#end
}
