// See the file "LICENSE" for the full license governing this code

package minject.point;

import minject.Injector;

class PropertyInjectionPoint implements InjectionPoint
{
	public var field(default, null):String;
	public var type(default, null):String;
	public var name(default, null):String;

	public function new(field:String, type:String, ?name:String=null)
	{
		this.field = field;
		this.type = type;
		this.name = name;
	}

	public function applyInjection(target:Dynamic, injector:Injector):Dynamic
	{
		var response = injector.getValueForType(type, name);

		#if debug
		if (response == null)
		{
			var targetName = Type.getClassName(Type.getClass(target));
			throw 'Injector is missing a mapping to handle injection into property "$field" of ' +
				'object "$targetName". Target dependency: "$type", named "$name"';
		}
		#end

		Reflect.setProperty(target, field, response);
		return target;
	}
}
