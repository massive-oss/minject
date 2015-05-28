// See the file "LICENSE" for the full license governing this code

package minject.point;

import massive.munit.Assert;
import minject.Injector;
import minject.support.injectees.OneParameterConstructorInjectee;
import minject.support.types.Class1;

@:keep class ConstructorInjectionPointTest
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
		var point = new ConstructorInjectionPoint(['minject.support.types.Class1', '', '']);

		injector.map(Class1).asSingleton();
		var injectee = point.createInstance(OneParameterConstructorInjectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency(), Class1));
	}
}
