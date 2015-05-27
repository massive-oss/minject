/*
Copyright (c) 2012-2015 Massive Interactive

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

class InjectorRule
{
	public var type:String;
	public var name:String;
	public var injector:Injector;
	public var result:InjectionResult;

	public function new(type:String, name:String)
	{
		this.type = type;
		this.name = name;
	}

	public function getResponse(injector:Injector):Dynamic
	{
		if (this.injector != null) injector = this.injector;

		if (result != null)
			return result.getResponse(injector);

		var parent = injector.findRuleForTypeId(type, name);
		if (parent != null)
			return parent.getResponse(injector);

		return null;
	}

	public function setResult(result:InjectionResult):Void
	{
		#if debug
		if (this.result != null && result != null)
		{
			trace('Warning: Injector contains ${this.toString()}.\nAttempting to overwrite this ' +
				'with mapping for ${result.toString()}.\nIf you have overwritten this mapping ' +
				'intentionally you can use `injector.unmap()` prior to your replacement mapping ' +
				'in order to avoid seeing this message.');
		}
		#end
		this.result = result;
	}

	#if debug
	public function toString():String
	{
		var named = name != null && name != '' ? ' named "$name" and' : '';
		return 'rule: [$type]$named mapped to [$result]';
	}
	#end
}
