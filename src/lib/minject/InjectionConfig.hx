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

package minject;

import minject.result.InjectionResult;

class InjectionConfig
{
	public var request:Class<Dynamic>;
	public var injectionName:String;

	var injector:Injector;
	var result:InjectionResult;
	
	public function new(request:Class<Dynamic>, injectionName:String)
	{
		this.request = request;
		this.injectionName = injectionName;
	}

	public function getResponse(injector:Injector):Dynamic
	{
		if (this.injector != null) injector = this.injector;

		if (result != null)
		{
			return result.getResponse(injector);
		}
		
		var parentConfig = injector.getAncestorMapping(request, injectionName);

		if (parentConfig != null)
		{
			return parentConfig.getResponse(injector);
		}

		return null;
	}

	public function hasResponse(injector:Injector):Bool
	{
		return (result != null);
	}

	public function hasOwnResponse():Bool
	{
		return (result != null);
	}

	public function setResult(result:InjectionResult):Void
	{
		if (this.result != null && result != null)
		{
			trace('Warning: Injector already has a rule for type "' + 
			Type.getClassName(request) + '", named "' + injectionName + 
			'".\nIf you have overwritten this mapping intentionally ' +
			'you can use "injector.unmap()" prior to your replacement ' +
			'mapping in order to avoid seeing this message.');
		}

		this.result = result;
	}

	public function setInjector(injector:Injector):Void
	{
		this.injector = injector;
	}
}
