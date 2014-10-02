/*
Copyright (c) 2012-2014 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

package minject.point;

import minject.Injector;

class MethodInjectionPoint implements InjectionPoint
{
	public var name(default, null):String;
	public var args(default, null):Array<ArgInjectionInfo>;

	var requestNames:Array<String>;
	
	public function new(name:String, args:Array<ArgInjectionInfo>)
	{
		this.name = name;
		this.args = args;

		#if debug
		for (arg in args)
			if (arg.type == "Dynamic")
				throw 'Error in method definition of injectee. Required parameters can\'t have non class type.';
		#end

		makeRequestNames();
	}

	function makeRequestNames():Void
	{
		requestNames = [];
		for (i in 0...args.length) {
			var arg = args[i];
			var requestName:String = RequestHasher.resolveRequest(Type.resolveClass(arg.type), arg.name);
			requestNames.push(requestName);
		}
	}

	public function applyInjection(target:Dynamic, injector:Injector):Dynamic
	{
		Reflect.callMethod(target, Reflect.field(target, name), gatherArgs(target, injector));
		return target;
	}
	
	function gatherArgs(target:Dynamic, injector:Injector):Array<Dynamic>
	{
		var values = [];
		for (i in 0...args.length)
		{
			var arg = args[i];
			var name = arg.name == null ? "" : arg.name;
			var config = injector.getConfig(requestNames[i]);
			if(arg.opt && config == null) {
				values.push(null);
				continue;
			}
			var injection = config.getResponse(injector);

			#if debug
			if (injection == null && !arg.opt)
			{
				var targetName = Type.getClassName(Type.getClass(target));
				var requestName = Type.getClassName(config.request);
				throw 'Injector is missing a rule to handle injection into target $targetName. ' +
					'Target dependency: $requestName, method: $name, named: ' + arg.name;
			}
			#end
			values.push(injection);
		}

		return values;
	}
}

typedef ArgInjectionInfo = {
	var opt:Bool;
	var type:String;
	@:optional var name:String;
}
