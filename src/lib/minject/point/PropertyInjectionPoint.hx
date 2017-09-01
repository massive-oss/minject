// See the file "LICENSE" for the full license governing this code

package minject.point;

import minject.Injector;

class PropertyInjectionPoint implements InjectionPoint
{
	public var field(default, null):String;
	public var type(default, null):String;
	public var name(default, null):String;
	public var optional(default, null):Bool;

	public function new(field:String, type:String, ?name:String=null, optional:Bool = false)
	{
		this.field = field;
		this.type = type;
		this.name = name;
		this.optional = optional;
	}

	public function applyInjection(target:Dynamic, injector:Injector):Dynamic
	{
		var response = injector.getValueForType(type, name);

		// When don't have a response and the injection is optional, simply return the target
		if(response == null && optional)
			return target;

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
