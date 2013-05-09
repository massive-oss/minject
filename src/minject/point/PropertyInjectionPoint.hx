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

class PropertyInjectionPoint extends InjectionPoint
{
	var propertyName:String;
	var propertyType:String;
	var injectionName:String;

	public function new(meta:Dynamic, ?injector:Injector=null)
	{
		super(meta, null);
	}
	
	public override function applyInjection(target:Dynamic, injector:Injector):Dynamic
	{
		var injectionConfig:InjectionConfig = injector.getMapping(Type.resolveClass(propertyType), injectionName);
		var injection:Dynamic = injectionConfig.getResponse(injector);

		if (injection == null)
		{
			throw 'Injector is missing a rule to handle injection into property "' + propertyName + '" of object "' + target + '". Target dependency: "' + propertyType + '", named "' + injectionName + '"';
		}

		Reflect.setProperty(target, propertyName, injection);
		
		return target;
	}
	
	override function initializeInjection(meta:Dynamic):Void
	{
		propertyType = meta.type[0];
		propertyName = meta.name[0];

		if (meta.inject == null)
		{
			injectionName = "";
		}
		else
		{
			injectionName = meta.inject[0];
		}
	}
}
