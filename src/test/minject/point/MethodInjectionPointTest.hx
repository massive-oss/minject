// See the file "LICENSE" for the full license governing this code

package minject.point;

import massive.munit.Assert;
import minject.Injector;
import minject.support.injectees.OneRequiredOneOptionalPropertyMethodInjectee;
import minject.support.injectees.TwoParametersMethodInjectee;
import minject.support.injectees.OneNamedParameterMethodInjectee;
import minject.support.injectees.OneParameterMethodInjectee;
import minject.support.types.Class1;
import minject.support.types.Interface1;

@:keep class MethodInjectionPointTest
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
		var injectionPoint = new MethodInjectionPoint('setDependency', ['minject.support.types.Class1','name','']);

		injector.map(Class1, 'name').asSingleton();
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency(), Class1));
	}

	@Test
	public function injection_of_two_unnamed_properties_into_method()
	{
		var injectee = new TwoParametersMethodInjectee();
		var injectionPoint = new MethodInjectionPoint('setDependencies', ['minject.support.types.Class1','','','minject.support.types.Interface1','','']);

		injector.map(Class1).asSingleton();
		injector.map(Interface1).toSingleton(Class1);
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency1(), Class1));
		Assert.isTrue(Std.is(injectee.getDependency2(), Interface1));
	}

	@Test
	public function injection_of_one_required_one_optional_parameter_into_method()
	{
		var injectee = new OneRequiredOneOptionalPropertyMethodInjectee();
		var injectionPoint = new MethodInjectionPoint('setDependencies', ['minject.support.types.Class1','','','minject.support.types.Interface1','','o']);

		injector.map(Class1).asSingleton();
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency1(), Class1));
		Assert.isTrue(injectee.getDependency2() == null);
	}

	@Test
	public function injection_of_unmapped_parameter_into_method_throws_exception()
	{
		var injectee = new OneParameterMethodInjectee();
		var injectionPoint = new MethodInjectionPoint('setDependency', ['minject.support.types.Class1','name','']);
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
