package minject.point;

import massive.munit.Assert;
import minject.Injector;
import minject.support.injectees.ClassInjectee;

class PostConstructInjectionPointTest
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
	public function post_construction_injection_into_method_with_order()
	{
		var injectee = new ClassInjectee();
		var meta = {inject:null, name:["doSomeStuff"], post:[1]};
		var injectionPoint = new PostConstructInjectionPoint(meta);
		injectionPoint.applyInjection(injectee, injector);
		Assert.isTrue(injectee.someProperty);
	}

	@Test
	public function post_construction_injection_into_method_without_order()
	{
		var injectee = new ClassInjectee();
		var meta = {inject:null, name:["doSomeStuff"], post:null};
		var injectionPoint = new PostConstructInjectionPoint(meta);
		injectionPoint.applyInjection(injectee, injector);
		Assert.isTrue(injectee.someProperty);
	}
}
