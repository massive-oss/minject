// See the file "LICENSE" for the full license governing this code

package minject.point;

import minject.Injector;
import minject.point.MethodInjectionPoint;

class ConstructorInjectionPoint extends MethodInjectionPoint
{
	public function new(args:Array<String>)
	{
		super('new', args);
	}

	public function createInstance<T>(type:Class<T>, injector:Injector):T
	{
		return Type.createInstance(type, gatherArgs(type, injector));
	}
}
