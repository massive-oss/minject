// See the file "LICENSE" for the full license governing this code

package minject.provider;

import minject.Injector;

class ValueProvider<T> implements DependencyProvider<T>
{
	var value:T;

	public function new(value:T)
	{
		this.value = value;
	}

	public function getValue(injector:Injector):T
	{
		return value;
	}

	#if debug
	public function toString():String
	{
		return 'instance of ' + Type.getClassName(Type.getClass(value));
	}
	#end
}
