package minject.point;

import massive.munit.Assert;
import minject.support.injectees.ClassInjectee;

class NoParamsConstructorInjectionPointTest
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
	public function no_params_constructor_injection_point_is_constructed()
	{
		var injectionPoint = new NoParamsConstructorInjectionPoint();
		var instance = injectionPoint.applyInjection(ClassInjectee, injector);
		Assert.isTrue(Std.is(instance, ClassInjectee));
	}
}
