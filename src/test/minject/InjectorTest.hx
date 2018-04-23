// See the file 'LICENSE' for the full license governing this code

package minject;

import Type;

import massive.munit.Assert;
import minject.support.injectees.*;
import minject.support.injectees.AnonTypedefInjectee;
import minject.support.injectees.TypedefInjectee;
import minject.support.injectees.RecursiveInjectee;
import minject.support.types.*;

@:keep class InjectorTest
 {
	public function new(){}

	var injector:Injector;

	@Before
	public function setup():Void
	{
		injector = new Injector();
	}

	@After
	public function tear_down():Void
	{
		injector = null;
	}

	@Test
	public function unbind()
	{
		var injectee = new ClassInjectee();
		var value = new Class1();

		injector.map(Class1).toValue(value);
		injector.unmap(Class1);

		try
		{
			injector.injectInto(injectee);
		}
		catch(e:Dynamic)
		{
		}

		Assert.areEqual(null, injectee.property);
	}

	@Test
	public function injector_injects_bound_value_into_all_injectees():Void
	{
		var value = new Class1();
		injector.map(Class1).toValue(value);

		var injectee1 = new ClassInjectee();
		injector.injectInto(injectee1);

		var injectee2 = new ClassInjectee();
		injector.injectInto(injectee2);

		Assert.areEqual(value, injectee1.property);
		Assert.areEqual(injectee1.property, injectee2.property);
	}

	@Test
	public function bind_value_by_interface():Void
	{
		var injectee = new InterfaceInjectee();
		var value = new Class1();

		injector.map(Interface1).toValue(value);
		injector.injectInto(injectee);
		Assert.areEqual(value, injectee.property);
	}

	@Test
	public function bind_named_value():Void
	{
		var injectee = new NamedClassInjectee();
		var value = new Class1();

		injector.map(Class1, NamedClassInjectee.NAME).toValue(value);
		injector.injectInto(injectee);
		Assert.areEqual(value, injectee.property);
	}

	@Test
	public function bind_named_value_by_interface():Void
	{
		var injectee = new NamedInterfaceInjectee();
		var value = new Class1();

		injector.map(Interface1, NamedClassInjectee.NAME).toValue(value);
		injector.injectInto(injectee);
		Assert.areEqual(value, injectee.property);
	}

	@Test
	public function bind_falsy_value():Void
	{
		var injectee = new StringInjectee();
		var value = 'test';

		injector.map(String).toValue(value);
		injector.injectInto(injectee);

		Assert.areEqual(value, injectee.property);
	}

	@Test
	public function bound_value_is_not_injected_into():Void
	{
		var injectee = new RecursiveInterfaceInjectee();
		var value = new InterfaceInjectee();

		injector.map(InterfaceInjectee).toValue(value);
		injector.injectInto(injectee);

		Assert.isNull(value.property);
	}

	@Test
	public function bind_multiple_interfaces_to_one_singleton_class():Void
	{
		var injectee = new MultipleSingletonsOfSameClassInjectee();

		injector.map(Interface1).toSingleton(Class1);
		injector.map(Interface2).toSingleton(Class1);

		injector.injectInto(injectee);
		Assert.isNotNull(injectee.property1);
		Assert.isNotNull(injectee.property2);

		// in haxe you can't compare types which the compiler knows cannot be the same
		var same = untyped (injectee.property1 == injectee.property2);
		Assert.isFalse(same);
	}

	@Test
	public function bind_class():Void
	{
		injector.map(Class1).toClass(Class1);

		var injectee1 = new ClassInjectee();
		injector.injectInto(injectee1);

		var injectee2 = new ClassInjectee();
		injector.injectInto(injectee2);

		Assert.isNotNull(injectee1.property);
		Assert.isFalse(injectee1.property == injectee2.property);
	}

	@Test
	public function bind_inherited_class():Void
	{
		injector.map(Class1).toClass(Class1);
		injector.map(Class2).toClass(Class2);

		var injectee1 = new InheritanceInjectee();
		injector.injectInto(injectee1);

		var injectee2 = new InheritanceInjectee();
		injector.injectInto(injectee2);

		Assert.isNotNull(injectee1.property);
		Assert.isNotNull(injectee1.property2);
		Assert.isTrue(injectee1.someProperty);
		Assert.isTrue(injectee1.extraProperty);
		Assert.isFalse(injectee1.property == injectee2.property);
		Assert.isFalse(injectee1.property2 == injectee2.property2);
	}

	@Test
	public function bind_typedef():Void
	{
		injector.map(Typedef1).toClass(Typedef1);
		injector.map(TypedefInjectee).toClass(TypedefInjectee);

		Assert.isTrue(injector.hasMapping(Typedef1));
		Assert.isTrue(injector.hasMapping(Class1));

		var injectee1 = new TypedefInjectee();
		injector.injectInto(injectee1);

		Assert.isNotNull(injectee1.property);
	}

	@Test
	public function bind_type_params():Void
	{
		// These 2 mappings should match on the full type, so do not need a name.
		injector.map('Array<String>').toValue(['Jason', 'David']);
		injector.map('Array<Int>').toValue([0,1,2]);
		// These 2 mappings should match an Array with any type parameter - hence the need for names.
		injector.map('Array<String>', 'cities').toValue(['London', 'Sydney', 'Perth']);
		injector.map('Array<Int>', 'populations').toValue([8416535,4840600,2021200]);

		var injectee = new TypeParamInjectee();
		injector.injectInto(injectee);

		Assert.areEqual('Jason', injectee.names[0]);
		Assert.areEqual(0, injectee.numbers[0]);
		Assert.areEqual('London', injectee.cities[0]);
		Assert.areEqual(8416535, injectee.populations[0]);
	}

	@Test
	public function bound_class_is_injected_into():Void
	{
		var injectee = new ComplexClassInjectee();
		var value = new Class1();

		injector.map(Class1).toValue(value);
		injector.map(ComplexClass).toClass(ComplexClass);
		injector.injectInto(injectee);

		Assert.isNotNull(injectee.property);
		Assert.areEqual(value, injectee.property.value);
	}

	@Test
	public function bind_class_by_interface():Void
	{
		var injectee = new InterfaceInjectee();
		injector.map(Interface1).toClass(Class1);
		injector.injectInto(injectee);
		Assert.isNotNull(injectee.property);
	}

	@Test
	public function bind_named_class():Void
	{
		var injectee = new NamedClassInjectee();
		injector.map(Class1, NamedClassInjectee.NAME).toClass(Class1);
		injector.injectInto(injectee);
		Assert.isNotNull(injectee.property);
	}

	@Test
	public function bind_named_class_by_interface():Void
	{
		var injectee = new NamedInterfaceInjectee();
		injector.map(Interface1, NamedClassInjectee.NAME).toClass(Class1);
		injector.injectInto(injectee);
		Assert.isNotNull(injectee.property);
	}

	@Test
	public function bind_singleton():Void
	{
		var injectee1 = new ClassInjectee();
		var injectee2 = new ClassInjectee();

		injector.map(Class1).asSingleton();

		injector.injectInto(injectee1);
		Assert.isNotNull(injectee1.property);

		injector.injectInto(injectee2);
		Assert.areEqual(injectee1.property, injectee2.property);
	}

	@Test
	public function bind_singleton_of():Void
	{
		var injectee1 = new InterfaceInjectee();
		var injectee2 = new InterfaceInjectee();

		injector.map(Interface1).toSingleton(Class1);

		injector.injectInto(injectee1);
		Assert.isNotNull(injectee1.property);

		injector.injectInto(injectee2);
		Assert.areEqual(injectee1.property, injectee2.property);
	}

	@Test
	public function bind_differently_named_singletons_by_same_interface():Void
	{
		var injectee = new TwoNamedInterfaceFieldsInjectee();

		injector.map(Interface1, TwoNamedInterfaceFieldsInjectee.NAME1).toSingleton(Class1);
		injector.map(Interface1, TwoNamedInterfaceFieldsInjectee.NAME2).toSingleton(Class2);

		injector.injectInto(injectee);

		Assert.isTrue(Std.is(injectee.property1, Class1));
		Assert.isTrue(Std.is(injectee.property2, Class2));
		Assert.isFalse(injectee.property1 == injectee.property2);
	}

	@Test
	public function bind_anonymous_structure_typedef():Void
	{
		var injectee = new AnonTypedefInjectee();

		var myGreeter = {
			name:'world',
			hello:function(name) {
				return 'hello ' + name;
			}
		};

		injector.map('minject.support.injectees.Greeter').toValue(myGreeter);
		injector.injectInto(injectee);
		Assert.isNotNull(injectee.property);
	}

	@Test
	public function bind_anonymous_structure_typedef_by_reference():Void
	{
		var injectee = new AnonTypedefInjectee();

		var myGreeter:Greeter = {
			name:'world',
			hello:function(name) {
				return 'hello ' + name;
			}
		};

		injector.injectValue(myGreeter);
		injector.injectInto(injectee);
		Assert.isNotNull(injectee.property);
	}

	@Test
	public function bind_anonymous_structure_typedef_by_fieds_string():Void
	{
		var injectee = new AnonTypedefInjectee();

		var myGreeter:Greeter = {
			name:'world',
			hello:function(name) {
				return 'hello ' + name;
			}
		};

		var greeter = 'minject.support.injectees.Greeter';
		injector.mapType(greeter).toValue(myGreeter);
		injector.injectInto(injectee);
		Assert.isNotNull(injectee.property);
	}

	@Test
	public function perform_setter_injection():Void
	{
		var injectee1 = new SetterInjectee();
		var injectee2 = new SetterInjectee();

		injector.map(Class1).toClass(Class1);

		injector.injectInto(injectee1);
		Assert.isNotNull(injectee1.property);

		injector.injectInto(injectee2);
		Assert.isFalse(injectee1.property == injectee2.property);
	}

	@Test
	public function perform_method_injection_with_one_parameter():Void
	{
		var injectee1 = new OneParameterMethodInjectee();
		var injectee2 = new OneParameterMethodInjectee();

		injector.map(Class1).toClass(Class1);

		injector.injectInto(injectee1);
		Assert.isNotNull(injectee1.getDependency());

		injector.injectInto(injectee2);
		Assert.isFalse(injectee1.getDependency() == injectee2.getDependency());
	}

	@Test
	public function perform_method_injection_with_one_named_parameter():Void
	{
		var injectee1 = new OneNamedParameterMethodInjectee();
		var injectee2 = new OneNamedParameterMethodInjectee();

		injector.map(Class1, OneNamedParameterMethodInjectee.NAME).toClass(Class1);

		injector.injectInto(injectee1);
		Assert.isNotNull(injectee1.getDependency());

		injector.injectInto(injectee2);
		Assert.isFalse(injectee1.getDependency() == injectee2.getDependency());
	}

	@Test
	public function perform_method_injection_with_two_parameters():Void
	{
		var injectee1 = new TwoParametersMethodInjectee();
		var injectee2 = new TwoParametersMethodInjectee();

		injector.map(Class1).toClass(Class1);
		injector.map(Interface1).toClass(Class1);

		injector.injectInto(injectee1);
		Assert.isNotNull(injectee1.getDependency1());
		Assert.isNotNull(injectee1.getDependency2());

		injector.injectInto(injectee2);
		Assert.isFalse(injectee1.getDependency1() == injectee2.getDependency1());
		Assert.isFalse(injectee1.getDependency2() == injectee2.getDependency2());
	}

	@Test
	public function perform_method_injection_with_two_named_parameters():Void
	{
		var injectee1 = new TwoNamedParametersMethodInjectee();
		var injectee2 = new TwoNamedParametersMethodInjectee();

		injector.map(Class1, TwoNamedParametersMethodInjectee.NAME1).toClass(Class1);
		injector.map(Interface1, TwoNamedParametersMethodInjectee.NAME2).toClass(Class1);

		injector.injectInto(injectee1);
		Assert.isNotNull(injectee1.getDependency1());
		Assert.isNotNull(injectee1.getDependency2());

		injector.injectInto(injectee2);
		Assert.isFalse(injectee1.getDependency1() == injectee2.getDependency1());
		Assert.isFalse(injectee1.getDependency2() == injectee2.getDependency2());
	}

	@Test
	public function perform_method_injection_with_mixed_parameters():Void
	{
		var injectee1 = new MixedParametersMethodInjectee();
		var injectee2 = new MixedParametersMethodInjectee();

		injector.map(Class1, MixedParametersMethodInjectee.NAME1).toClass(Class1);
		injector.map(Class1).toClass(Class1);
		injector.map(Interface1, MixedParametersMethodInjectee.NAME2).toClass(Class1);

		injector.injectInto(injectee1);
		Assert.isNotNull(injectee1.getDependency1());
		Assert.isNotNull(injectee1.getDependency2());
		Assert.isNotNull(injectee1.getDependency3());

		injector.injectInto(injectee2);
		Assert.isFalse(injectee1.getDependency1() == injectee2.getDependency1());
		Assert.isFalse(injectee1.getDependency2() == injectee2.getDependency2());
		Assert.isFalse(injectee1.getDependency3() == injectee2.getDependency3());
	}

	@Test
	public function perform_constructor_injection_with_one_parameter():Void
	{
		injector.map(Class1).toClass(Class1);

		var injectee = injector.instantiate(OneParameterConstructorInjectee);
		Assert.isNotNull(injectee.getDependency());
	}

	@Test
	public function perform_constructor_injection_with_two_parameters():Void
	{
		injector.map(Class1).toClass(Class1);
		injector.map(String).toValue('stringDependency');

		var injectee = injector.instantiate(TwoParametersConstructorInjectee);

		Assert.isNotNull(injectee.getDependency1());
		Assert.areEqual(injectee.getDependency2(), 'stringDependency');
	}

	@Test
	public function perform_constructor_injection_with_one_named_parameter():Void
	{
		injector.map(Class1, OneNamedParameterConstructorInjectee.NAME).toClass(Class1);
		var injectee = injector.instantiate(OneNamedParameterConstructorInjectee);
		Assert.isNotNull(injectee.getDependency());
	}

	@Test
	public function perform_constructor_injection_with_two_named_parameter():Void
	{
		var stringValue = 'stringDependency';
		injector.map(Class1, TwoNamedParametersConstructorInjectee.NAME1).toClass(Class1);
		injector.map(String, TwoNamedParametersConstructorInjectee.NAME2).toValue(stringValue);

		var injectee = injector.instantiate(TwoNamedParametersConstructorInjectee);
		Assert.isNotNull(injectee.getDependency1());
		Assert.areEqual(injectee.getDependency2(), stringValue);
	}

	@Test
	public function perform_constructor_injection_with_mixed_parameters():Void
	{
		injector.map(Class1, MixedParametersConstructorInjectee.NAME1).toClass(Class1);
		injector.map(Class1).toClass(Class1);
		injector.map(Interface1, MixedParametersConstructorInjectee.NAME2).toClass(Class1);

		var injectee = injector.instantiate(MixedParametersConstructorInjectee);
		Assert.isNotNull(injectee.getDependency1());
		Assert.isNotNull(injectee.getDependency2());
		Assert.isNotNull(injectee.getDependency3());
	}

	@Test
	public function perform_named_array_injection():Void
	{
		var array = ['value1', 'value2', 'value3'];

		injector.map('Array<String>', NamedArrayInjectee.NAME).toValue(array);
		var injectee = injector.instantiate(NamedArrayInjectee);

		Assert.isNotNull(injectee.array);
		Assert.areEqual(array, injectee.array);
	}

	@Test
	public function perform_mapped_mapping_injection():Void
	{
		var mapping = injector.map(Interface1).toSingleton(Class1);
		injector.map(Interface2).toMapping(mapping);

		var injectee = injector.instantiate(MultipleSingletonsOfSameClassInjectee);
		Assert.areEqual(injectee.property1, injectee.property2);
	}

	@Test
	public function perform_mapped_named_mapping_injection():Void
	{
		var mapping = injector.map(Interface1).toSingleton(Class1);

		injector.map(Interface2).toMapping(mapping);
		injector.map(Interface1, MultipleNamedSingletonsOfSameClassInjectee.NAME1).toMapping(mapping);
		injector.map(Interface2, MultipleNamedSingletonsOfSameClassInjectee.NAME2).toMapping(mapping);

		var injectee = injector.instantiate(MultipleNamedSingletonsOfSameClassInjectee);
		Assert.areEqual(injectee.property1, injectee.property2);
		Assert.areEqual(injectee.property1, injectee.namedProperty1);
		Assert.areEqual(injectee.property1, injectee.namedProperty2);
	}

	@Test
	public function perform_injection_into_value_with_recursive_singelton_dependency():Void
	{
		var injectee = new InterfaceInjectee();

		injector.map(InterfaceInjectee).toValue(injectee);
		injector.map(Interface1).toSingleton(RecursiveInterfaceInjectee);

		injector.injectInto(injectee);
		Assert.isTrue(true);
	}

	@Test
	public function inject_x_m_l_value() : Void
	{
		var injectee = new XMLInjectee();
		var value = Xml.parse('<test/>');

		injector.map(Xml).toValue(value);
		injector.injectInto(injectee);

		Assert.areEqual(injectee.property, value);
	}

	@Test
	public function post_construct_is_called():Void
	{
		var injectee = new ClassInjectee();
		var value = new Class1();

		injector.map(Class1).toValue(value);
		injector.injectInto(injectee);

		Assert.isTrue(injectee.someProperty);
	}

	@Test
	public function post_construct_methods_called_as_ordered():Void
	{
		var injectee = new OrderedPostConstructInjectee();
		injector.injectInto(injectee);

		Assert.isTrue(injectee.loadedAsOrdered);
	}

	@Test
	public function has_mapping_fails_for_unmapped_unnamed_class():Void
	{
		Assert.isFalse(injector.hasMapping(Class1));
	}

	@Test
	public function has_mapping_fails_for_unmapped_named_class():Void
	{
		Assert.isFalse(injector.hasMapping(Class1, 'namedClass'));
	}

	@Test
	public function has_mapping_succeeds_for_mapped_unnamed_class():Void
	{
		injector.map(Class1).toClass(Class1);
		Assert.isTrue(injector.hasMapping(Class1));
	}

	@Test
	public function has_mapping_succeeds_for_mapped_named_class():Void
	{
		injector.map(Class1, 'namedClass').toClass(Class1);
		Assert.isTrue(injector.hasMapping(Class1, 'namedClass'));
	}

	@Test
	public function get_mapping_response_succeeds_for_mapped_unnamed_class():Void
	{
		var class1 = new Class1();
		injector.map(Class1).toValue(class1);
		Assert.areEqual(injector.getInstance(Class1), class1);
	}

	@Test
	public function get_mapping_response_succeeds_for_mapped_named_class():Void
	{
		var class1 = new Class1();
		injector.map(Class1, 'namedClass').toValue(class1);
		Assert.areEqual(injector.getInstance(Class1, 'namedClass'), class1);
	}

	@Test
	public function injector_removes_singleton_instance_on_mapping_removal():Void
	{
		injector.map(Class1).asSingleton();

		var injectee1 = injector.instantiate(ClassInjectee);
		injector.unmap(Class1);
		injector.map(Class1).asSingleton();

		var injectee2 = injector.instantiate(ClassInjectee);
		Assert.isFalse(injectee1.property == injectee2.property);
	}

	@Test
	public function halt_on_missing_dependency():Void
	{
		var injectee = new InterfaceInjectee();
		var passed = false;

		try
		{
			injector.injectInto(injectee);
		}
		catch (e:Dynamic)
		{
			passed = true;
		}

		Assert.isTrue(passed);
	}

	@Test
	public function halt_on_missing_named_dependency():Void
	{
		var injectee = new NamedClassInjectee();
		var passed = false;

		try
		{
			injector.injectInto(injectee);
		}
		catch (e:Dynamic)
		{
			passed = true;
		}

		Assert.isTrue(passed);
	}

	@Test
	public function get_mapping_response_fails_for_unmapped_unnamed_class():Void
	{
		var passed = false;

		try
		{
			injector.getInstance(Class1);
		}
		catch (e:Dynamic)
		{
			passed = true;
		}

		Assert.isTrue(passed);
	}

	@Test
	public function get_mapping_response_fails_for_unmapped_named_class():Void
	{
		var passed = false;

		try
		{
			injector.getInstance(Class1, 'namedClass');
		}
		catch (e:Dynamic)
		{
			passed = true;
		}

		Assert.isTrue(passed);
	}

	@Test
	public function instantiate_throws_meaningful_error_on_interface_instantiation() : Void
	{
		var passed = false;

		try
		{
			injector.instantiate(Interface1);
		}
		catch (e:Dynamic)
		{
			passed = true;
		}

		Assert.isTrue(passed);
	}

	@Test
	public function should_instantiate_recursive_injectee()
	{
		injector.map(RecursiveInjectee1).asSingleton();
		injector.map(RecursiveInjectee2).asSingleton();
		injector.instantiate(RecursiveInjectee1);
	}

	@Test
	public function should_get_response()
	{
		injector.map(Int, 'sessionExpiry').toValue(10);
		var value = injector.getValue(Int, 'sessionExpiry');
		Assert.areEqual(10, value);
	}

	@Test
	public function should_map_type_by_class_reference()
	{
		var reference = Class1;
		injector.mapRuntimeTypeOf(reference).toValue(new Class1());
		Assert.isTrue(injector.hasMapping(Class1));
	}

	@Test
	public function should_map_type_by_instance_reference()
	{
		var reference = new Class1();
		injector.mapTypeOf(reference).toValue(new Class1());
		Assert.isTrue(injector.hasMapping(Class1));
	}

	@Test
	public function should_map_type_by_enum_reference()
	{
		var reference = ValueType;
		injector.mapRuntimeTypeOf(reference).toValue(TObject);
		Assert.isTrue(injector.hasMapping(ValueType));
	}

	@Test
	public function should_map_type_by_enum_value_reference()
	{
		var reference = ValueType.TObject;
		injector.mapTypeOf(reference).toValue(TObject);
		Assert.isTrue(injector.hasMapping(ValueType));
	}
}
