package minject;

import minject.point.InjectionPoint;

class InjectorInfo
{
	public var ctor:InjectionPoint;
	public var fields:Array<InjectionPoint>;

	public function new(ctor:InjectionPoint, fields:Array<InjectionPoint>)
	{
		this.ctor = ctor;
		this.fields = fields;
	}
}
