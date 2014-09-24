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

import minject.RequestHasher;
import minject.Injector;

class PropertyInjectionPoint implements InjectionPoint
{
	var name:String;
	var type:Class<Dynamic>;
	var injectionName:String;
	var requestName:String;

	public function new(name:String, type:Class<Dynamic>, ?injectionName:String)
	{
		this.name = name;
		this.type = type;
		this.injectionName = injectionName;
		this.requestName = RequestHasher.resolveRequest(type, injectionName);
	}

	public function applyInjection(target:Dynamic, injector:Injector):Dynamic
	{
		var config = injector.getConfig(requestName);
		#if debug
		if (config == null)
		{
			var targetName = Type.getClassName(Type.getClass(target));
			throw 'Injector is missing a rule to handle injection into property "$name" ' +
				'of object "$targetName". Target dependency: "${Type.getClassName(type)}", named "$injectionName"';
		}
		#end
		Reflect.setProperty(target, name, config.getResponse(injector));
		return target;
	}


}
