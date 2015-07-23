// See the file "LICENSE" for the full license governing this code

package minject.point;

import minject.Injector;
import minject.point.MethodInjectionPoint;

class PostInjectionPoint extends MethodInjectionPoint
{
	public var order(default, null):Int;

	public function new(field:String, args:Array<String>, order:Int)
	{
		super(field, args);
		this.order = order;
	}
}
