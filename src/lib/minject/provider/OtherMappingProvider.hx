// See the file "LICENSE" for the full license governing this code

package minject.provider;

import minject.InjectorMapping;
import minject.Injector;

class OtherMappingProvider<T> implements DependencyProvider<T>
{
	var mapping:InjectorMapping<T>;

	public function new(mapping:InjectorMapping<T>)
	{
		this.mapping = mapping;
	}

	public function getValue(injector:Injector):T
	{
		return mapping.getValue(injector);
	}

	#if debug
	public function toString()
	{
		return mapping.toString();
	}
	#end
}
