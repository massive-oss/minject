// See the file "LICENSE" for the full license governing this code

package minject;

import minject.point.ConstructorInjectionPoint;
import minject.point.InjectionPoint;

class InjectorInfo
{
	public var ctor:ConstructorInjectionPoint;
	public var fields:Array<InjectionPoint>;

	public function new(ctor:ConstructorInjectionPoint, fields:Array<InjectionPoint>)
	{
		this.ctor = ctor;
		this.fields = fields;
	}
}
