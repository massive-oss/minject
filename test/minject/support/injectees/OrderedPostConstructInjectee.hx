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

package minject.support.injectees;

class OrderedPostConstructInjectee
{
	public var loadedAsOrdered:Bool;
	
	var one:Bool;
	var two:Bool;
	var three:Bool;
	var four:Bool;
	
	public function new()
	{
		loadedAsOrdered = false;
		one = two = three = four = false;
	}
	
	@post(2)
	public function methodTwo():Void
	{
		two = true;
		loadedAsOrdered = loadedAsOrdered && one && two && !three && !four;
	}
	
	@post(4)
	public function methodFour():Void
	{
		four = true;
		loadedAsOrdered = loadedAsOrdered && one && two && three && four;
	}
	
	@post(3)
	public function methodThree():Void
	{
		three = true;
		loadedAsOrdered = loadedAsOrdered && one && two && three && !four;
	}
	
	@post(1)
	public function methodOne():Void
	{
		one = true;
		loadedAsOrdered = one && !two && !three && !four;
	}
}
