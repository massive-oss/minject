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
import minject.support.injectees.OneRequiredOneOptionalPropertyMethodInjectee;
import minject.support.injectees.TwoParametersMethodInjectee;
import minject.support.injectees.OneNamedParameterMethodInjectee;
import minject.support.injectees.OneParameterMethodInjectee;
import minject.support.types.Class1;
import minject.support.types.Interface1;

class MethodInjectionPointTest
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
	public function injection_of_named_parameters_into_method()
	{
		var injectee = new OneNamedParameterMethodInjectee();
		var injectionPoint = new MethodInjectionPoint("setDependency", [{name:"name", type:"minject.support.types.Class1", opt:false}]);

		injector.mapSingleton(Class1, "name");
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency(), Class1));
	}

	@Test
	public function injection_of_two_unnamed_properties_into_method()
	{
		var injectee = new TwoParametersMethodInjectee();
		var injectionPoint = new MethodInjectionPoint("setDependencies", [{type:"minject.support.types.Class1", opt:false}, {type:"minject.support.types.Interface1", opt:false}]);

		injector.mapSingleton(Class1);
		injector.mapSingletonOf(Interface1, Class1);
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency1(), Class1));
		Assert.isTrue(Std.is(injectee.getDependency2(), Interface1));
	}

	@Test
	public function injection_of_one_required_one_optional_parameter_into_method()
	{
		var injectee = new OneRequiredOneOptionalPropertyMethodInjectee();
		var injectionPoint = new MethodInjectionPoint("setDependencies", [{type:"minject.support.types.Class1", opt:false}, {type:"minject.support.types.Interface1", opt:true}]);

		injector.mapSingleton(Class1);
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency1(), Class1));
		Assert.isTrue(injectee.getDependency2() == null);
	}

	@Test
	public function gathering_parameters_for_methods_with_untyped_parameters_throws_exception()
	{
		var passed = false;

		try
		{
			var injectionPoint = new MethodInjectionPoint("test", [{type:"Dynamic", opt:true}]);
		}
		catch (e:Dynamic)
		{
			passed = true;
		}

		Assert.isTrue(passed);
	}

	@Test
	public function injection_of_unmapped_parameter_into_method_throws_exception()
	{
		var injectee = new OneParameterMethodInjectee();
		var injectionPoint = new MethodInjectionPoint("setDependency", [{name:"name", type:"minject.support.types.Class1", opt:false}]);
		var passed = false;

		try
		{
			injectionPoint.applyInjection(injectee, injector);
		}
		catch (e:Dynamic)
		{
			passed = true;
		}

		Assert.isTrue(passed);
	}
}
