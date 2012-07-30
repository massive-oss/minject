/*
Copyright (c) 2012 Massive Interactive

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

import minject.InjectionConfig;
import minject.Injector;
import haxe.rtti.CType;
import mcore.util.Reflection;

class MethodInjectionPoint extends InjectionPoint
{
	var methodName:String;
	var _parameterInjectionConfigs:Array<Dynamic>;
	var requiredParameters:Int;
	
	public function new(meta:Dynamic, ?injector:Injector=null)
	{
		requiredParameters = 0;
		super(meta, injector);
	}
	
	override public function applyInjection(target:Dynamic, injector:Injector):Dynamic
	{
		var parameters:Array<Dynamic> = gatherParameterValues(target, injector);
		var method:Dynamic = Reflect.field(target, methodName);
		Reflection.callMethod(target, method, parameters);
		return target;
	}
	
	override function initializeInjection(meta:Dynamic):Void
	{
		methodName = meta.name[0];
		gatherParameters(meta);
	}
	
	function gatherParameters(meta:Dynamic):Void
	{
		var nameArgs = meta.inject;
		var args:Array<Dynamic> = meta.args;

		if (nameArgs == null) nameArgs = [];
		_parameterInjectionConfigs = [];

		var i = 0;
		for (arg in args)
		{
			var injectionName = "";

			if (i < nameArgs.length)
			{
				injectionName = nameArgs[i];
			}

			var parameterTypeName = arg.type;

			if (arg.opt)
			{
				if (parameterTypeName == "Dynamic")
				{
					//TODO: Find a way to trace name of affected class here
					throw 'Error in method definition of injectee. Required parameters can\'t have non class type.';
				}
			}
			else
			{
				requiredParameters++;
			}

			_parameterInjectionConfigs.push(new ParameterInjectionConfig(parameterTypeName, injectionName));
			
			i++;
		}
	}
	
	function gatherParameterValues(target:Dynamic, injector:Injector):Array<Dynamic>
	{

		var parameters: Array<Dynamic> = [];
		var length: Int = _parameterInjectionConfigs.length;

		for (i in 0...length)
		{
			var parameterConfig = _parameterInjectionConfigs[i];
			var config = injector.getMapping(Type.resolveClass(parameterConfig.typeName), parameterConfig.injectionName);
			
			var injection:Dynamic = config.getResponse(injector);
			if (injection == null)
			{
				if (i >= requiredParameters)
				{
					break;
				}
				
				throw 'Injector is missing a rule to handle injection into target ' + Type.getClassName(Type.getClass(target)) + '. Target dependency: ' + Type.getClassName(config.request) + ', method: ' + methodName + ', parameter: ' + (i + 1) + ', named: ' + parameterConfig.injectionName;
			}
			
			parameters[i] = injection;
		}

		return parameters;
	}
}

class ParameterInjectionConfig
{
	public var typeName:String;
	public var injectionName:String;

	public function new(typeName:String, injectionName:String)
	{
		this.typeName = typeName;
		this.injectionName = injectionName;
	}
}