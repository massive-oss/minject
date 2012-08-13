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

import massive.munit.Assert;
import minject.Injector;
import minject.support.injectees.ClassInjectee;
import minject.support.injectees.SetterInjectee;
import minject.support.injectees.NamedClassInjectee;
import minject.support.types.Class1;

class PropertyInjectionPointTest
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
	public function injection_of_single_property_is_applied():Void
	{
		injector.mapSingleton(Class1);

		var injectee = new ClassInjectee();
		var meta = {inject:null, name:["property"], type:["minject.support.types.Class1"]};
		var injectionPoint = new PropertyInjectionPoint(meta);
		injectionPoint.applyInjection(injectee, injector);
		
		Assert.isTrue(Std.is( injectee.property, Class1));
	}

	@Test
	public function injection_of_unmapped_property_type_throws_exception():Void
	{
		var injectee = new ClassInjectee();
		var meta = {inject:null, name:["property"], type:["minject.support.types.Class1"]};
		var injectionPoint = new PropertyInjectionPoint(meta);
		var threw = false;

		try
		{
			injectionPoint.applyInjection(injectee, injector);
		}
		catch (e:Dynamic)
		{
			threw = true;
		}
		
		Assert.isTrue(threw);
	}

	@Test
	public function injection_of_setter_is_applied():Void
	{
		injector.mapSingleton(Class1);

		var injectee = new SetterInjectee();
		var meta = {inject:null, setter:["set_property"], name:["property"], type:["minject.support.types.Class1"]};
		var injectionPoint = new PropertyInjectionPoint(meta);
		injectionPoint.applyInjection(injectee, injector);
		
		Assert.isTrue(Std.is( injectee.property, Class1));
	}

	@Test
	public function injection_of_named_property_is_applied():Void
	{
		injector.mapSingleton(Class1, "name");

		var injectee = new NamedClassInjectee();
		var meta = {inject:["name"], name:["property"], type:["minject.support.types.Class1"]};
		var injectionPoint = new PropertyInjectionPoint(meta);
		injectionPoint.applyInjection(injectee, injector);
		
		Assert.isTrue(Std.is( injectee.property, Class1));
	}
}
