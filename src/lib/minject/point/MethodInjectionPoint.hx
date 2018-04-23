// See the file "LICENSE" for the full license governing this code

package minject.point;

import minject.Injector;

class MethodInjectionPoint implements InjectionPoint
{
	public var field(default, null):String;
	public var args(default, null):Array<String>;

	public function new(field:String, args:Array<String>)
	{
		this.field = field;
		this.args = args;
	}

	public function applyInjection(target:Dynamic, injector:Injector):Dynamic
	{
		Reflect.callMethod(target, Reflect.field(target, field), gatherArgs(target, injector));
		return target;
	}

	function gatherArgs(target:Dynamic, injector:Injector):Array<Dynamic>
	{
		var values = [];
		var index = 0;

		while (index < args.length)
		{
			var type = args[index++];
			var argName = args[index++];
			var opt = args[index++] == 'o';

			var response = injector.getValueForType(type, argName);
			values.push(response);

			#if debug
			if (!opt && response == null)
			{
				var targetName = Type.getClassName(Type.getClass(target));
				throw 'Injector is missing a mapping to handle injection into target "$targetName". ' +
					'Target dependency: "$type", method: "$field", named: "$argName"';
			}
			#end
		}

		return values;
	}
}
