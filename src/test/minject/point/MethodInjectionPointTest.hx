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
		var meta = {inject:["name"], name:["setDependency"], args:[{type:"minject.support.types.Class1", opt:false}]};
		var injectionPoint = new MethodInjectionPoint(meta);

		injector.mapSingleton(Class1, "name");
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency(), Class1));
	}

	@Test
	public function injection_of_two_unnamed_properties_into_method()
	{
		var injectee = new TwoParametersMethodInjectee();
		var meta = {inject:null, name:["setDependencies"], args:[{type:"minject.support.types.Class1", opt:false}, {type:"minject.support.types.Interface1", opt:false}]};
		var injectionPoint = new MethodInjectionPoint(meta);
		
		injector.mapSingleton(Class1);
		injector.mapSingletonOf(Interface1, Class1);
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is(injectee.getDependency1(), Class1));
		//"dependency 1 should be Class1 instance"	
		Assert.isTrue(Std.is(injectee.getDependency2(), Interface1));
		//"dependency 2 should be Interface"
	}
	
	@Test
	public function injection_of_one_required_one_optional_parameter_into_method()
	{
		var injectee = new OneRequiredOneOptionalPropertyMethodInjectee();
		var meta = {inject:null, name:["setDependencies"], args:[{type:"minject.support.types.Class1", opt:false}, {type:"minject.support.types.Interface1", opt:true}]};
		var injectionPoint = new MethodInjectionPoint(meta);

		injector.mapSingleton(Class1);
		injectionPoint.applyInjection(injectee, injector);
		
		Assert.isTrue(Std.is(injectee.getDependency1(), Class1));
		Assert.isTrue(injectee.getDependency2() == null);
	}
	
	@Test
	public function gathering_parameters_for_methods_with_untyped_parameters_throws_exception()
	{
		var meta = {inject:null, name:["test"], args:[{type:"Dynamic", opt:true}]};
		var passed = false;

		try
		{
			var injectionPoint = new MethodInjectionPoint(meta, null);
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
		var meta = {inject:["name"], name:["setDependency"], args:[{type:"minject.support.types.Class1", opt:false}]};
		var injectionPoint = new MethodInjectionPoint(meta);
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
