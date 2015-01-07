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

package minject.point;

import massive.munit.Assert;
import minject.Injector;
import minject.support.injectees.OneParameterConstructorInjectee;
import minject.support.types.Class1;

class ConstructorInjectionPointTest
{
 	var injector:Injector;

	public function new(){}
	
	@Before
	public function before()
	{
		injector = new Injector();
	}

	@After
	public function after()
	{
		injector = null;
	}
	
	@Test
	public function one_parameter_constructor_injection()
	{
		var point = new ConstructorInjectionPoint([{type:"minject.support.types.Class1", opt:false}]);

		injector.mapSingleton(Class1);
		var injectee = point.applyInjection(OneParameterConstructorInjectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency(), Class1));
	}
}
