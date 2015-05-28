// See the file "LICENSE" for the full license governing this code

package minject.point;

import massive.munit.Assert;
import minject.Injector;
import minject.support.injectees.ClassInjectee;
import minject.support.injectees.SetterInjectee;
import minject.support.injectees.NamedClassInjectee;
import minject.support.types.Class1;

@:keep class PropertyInjectionPointTest
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
		injector.map(Class1).asSingleton();

		var injectee = new ClassInjectee();
		var injectionPoint = new PropertyInjectionPoint('property', 'minject.support.types.Class1');
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is( injectee.property, Class1));
	}

	@Test
	public function injection_of_unmapped_property_type_throws_exception():Void
	{
		var injectee = new ClassInjectee();
		var injectionPoint = new PropertyInjectionPoint('property', 'minject.support.types.Class1');
		var error = '';

		try
		{
			injectionPoint.applyInjection(injectee, injector);
		}
		catch (e:Dynamic)
		{
			error = e;
		}

		var expected:String = 'Injector is missing a mapping to handle injection into property "property" of object "minject.support.injectees.ClassInjectee". Target dependency: "minject.support.types.Class1", named "null"';
		#if js
		expected = StringTools.replace(expected, 'null', 'undefined');
		#end
		Assert.isTrue(error == expected);
	}

	@Test
	public function injection_of_setter_is_applied():Void
	{
		injector.map(Class1).asSingleton();

		var injectee = new SetterInjectee();
		var injectionPoint = new PropertyInjectionPoint('property', 'minject.support.types.Class1');
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is( injectee.property, Class1));
	}

	@Test
	public function injection_of_named_property_is_applied():Void
	{
		injector.map(Class1, 'name').asSingleton();

		var injectee = new NamedClassInjectee();
		var injectionPoint = new PropertyInjectionPoint('property', 'minject.support.types.Class1', 'name');
		injectionPoint.applyInjection(injectee, injector);

		Assert.isTrue(Std.is( injectee.property, Class1));
	}
}
