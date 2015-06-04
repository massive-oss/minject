// See the file "LICENSE" for the full license governing this code

package minject.provider;

import minject.Injector;

class SingletonProvider<T> implements DependencyProvider<T>
{
	var type:Class<T>;
	var value:T;

	public function new(type:Class<T>)
	{
		this.type = type;
	}

	public function getValue(injector:Injector):T
	{
		if (value == null)
		{
			value = injector._construct(type);
			injector.injectInto(value);
		}

		return value;
	}

	#if debug
	public function toString():String
	{
		return 'singleton ' + Type.getClassName(type);
	}
	#end
}
