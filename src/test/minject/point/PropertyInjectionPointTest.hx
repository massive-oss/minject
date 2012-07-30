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
