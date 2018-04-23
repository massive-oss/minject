// See the file "LICENSE" for the full license governing this code

package minject;

import massive.munit.Assert;

import minject.provider.*;
import minject.support.types.Class1;
import minject.support.types.Class1Extension;

@:keep class InjectorMappingTest
{
	public function new(){}

	var injector:Injector;

	@Before
	public function setup()
	{
		injector = new Injector();
	}

	@After
	public function teardown()
	{
		injector = null;
	}

	@Test
	public function mapping_is_instantiated():Void
	{
		var mapping = new InjectorMapping('minject.support.types.Class1', '');
		Assert.isTrue(Std.is(mapping, InjectorMapping));
	}

	@Test
	public function injection_type_value_returns_respone():Void
	{
		var response = new Class1();
		var mapping = new InjectorMapping('minject.support.types.Class1', '');
		mapping.toProvider(new ValueProvider(response));
		var returnedResponse = mapping.getValue(injector);

		Assert.areEqual(response, returnedResponse);
	}

	@Test
	public function injection_type_class_returns_respone():Void
	{
		var mapping = new InjectorMapping('minject.support.types.Class1', '');
		mapping.toProvider(new ClassProvider(Class1));
		var returnedResponse = mapping.getValue(injector);

		Assert.isTrue(Std.is(returnedResponse, Class1));
	}

	@Test
	public function injection_type_singleton_returns_response():Void
	{
		var mapping = new InjectorMapping('minject.support.types.Class1', '');
		mapping.toProvider(new SingletonProvider(Class1));
		var returnedResponse = mapping.getValue(injector);

		Assert.isTrue(Std.is(returnedResponse, Class1));
	}

	@Test
	public function same_singleton_is_returned_on_second_response():Void
	{
		var mapping = new InjectorMapping('minject.support.types.Class1', '');
		mapping.toProvider(new SingletonProvider(Class1));
		var returnedResponse = mapping.getValue(injector);
		var secondResponse = mapping.getValue(injector);

		Assert.areEqual(returnedResponse, secondResponse);
	}

	@Test
	public function same_named_singleton_is_returned_on_second_response():Void
	{
		var mapping = new InjectorMapping('minject.support.types.Class1', 'named');
		mapping.toProvider(new SingletonProvider(Class1));
		var returnedResponse = mapping.getValue(injector);
		var secondResponse = mapping.getValue(injector);

		Assert.areEqual(returnedResponse, secondResponse);
	}

	@Test
	public function calling_set_result_between_usages_changes_response():Void
	{
		var mapping = new InjectorMapping('minject.support.types.Class1', '');
		mapping.toProvider(new SingletonProvider(Class1));
		var returnedResponse = mapping.getValue(injector);
		mapping.toProvider(null);
		mapping.toProvider(new ClassProvider(Class1));
		var secondResponse = mapping.getValue(injector);

		Assert.isFalse(returnedResponse == secondResponse);
	}

	@Test
	public function injection_type_other_mapping_returns_other_mappings_response():Void
	{
		var mapping = new InjectorMapping('minject.support.types.Class1', '');
		var otherConfig = new InjectorMapping('minject.support.types.Class1Extension', '');
		otherConfig.toProvider(new ClassProvider(Class1Extension));
		mapping.toProvider(new OtherMappingProvider(otherConfig));
		var returnedResponse = mapping.getValue(injector);

		Assert.isTrue(Std.is(returnedResponse, Class1));
		Assert.isTrue(Std.is(returnedResponse, Class1Extension));
	}
}
