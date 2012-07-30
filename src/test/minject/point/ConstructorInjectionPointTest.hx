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
		var meta = {inject:null, name:["new"], args:[{type:"minject.support.types.Class1", opt:false}]};
		var point = new ConstructorInjectionPoint(meta, OneParameterConstructorInjectee);

		injector.mapSingleton(Class1);
		var injectee = point.applyInjection(OneParameterConstructorInjectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency(), Class1));
	}
}
