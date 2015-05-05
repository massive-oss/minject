/*
Copyright (c) 2012-2015 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package minject;

import massive.munit.Assert;
import minject.Injector;
import minject.support.injectees.ClassInjectee;
import minject.support.injectees.InheritanceInjectee;
import minject.support.injectees.TypedefInjectee;
import minject.support.injectees.TypeParamInjectee;
import minject.support.injectees.InterfaceInjectee;
import minject.support.injectees.NamedClassInjectee;
import minject.support.injectees.NamedInterfaceInjectee;
import minject.support.injectees.StringInjectee;
import minject.support.injectees.RecursiveInterfaceInjectee;
import minject.support.injectees.MultipleSingletonsOfSameClassInjectee;
import minject.support.injectees.ComplexClassInjectee;
import minject.support.injectees.TwoNamedInterfaceFieldsInjectee;
import minject.support.injectees.OneParameterMethodInjectee;
import minject.support.injectees.OneNamedParameterMethodInjectee;
import minject.support.injectees.TwoParametersMethodInjectee;
import minject.support.injectees.TwoNamedParametersMethodInjectee;
import minject.support.injectees.MixedParametersMethodInjectee;
import minject.support.injectees.OneParameterConstructorInjectee;
import minject.support.injectees.TwoParametersConstructorInjectee;
import minject.support.injectees.OneNamedParameterConstructorInjectee;
import minject.support.injectees.TwoNamedParametersConstructorInjectee;
import minject.support.injectees.MixedParametersConstructorInjectee;
import minject.support.injectees.NamedArrayInjectee;
import minject.support.injectees.MultipleNamedSingletonsOfSameClassInjectee;
import minject.support.injectees.XMLInjectee;
import minject.support.injectees.OrderedPostConstructInjectee;
import minject.support.types.Class1;
import minject.support.types.Class2;
import minject.support.types.Interface1;
import minject.support.types.Interface2;
import minject.support.types.ComplexClass;
import minject.support.injectees.SetterInjectee;
import minject.support.injectees.RecursiveInjectee;

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

		injector.mapValue(Class1, value);
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
		injector.mapValue(Class1, value);

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

		injector.mapValue(Interface1, value);
		injector.injectInto(injectee);
		Assert.areEqual(value, injectee.property);
	}

	@Test
	public function bind_named_value():Void
	{
		var injectee = new NamedClassInjectee();
		var value = new Class1();

		injector.mapValue(Class1, value, NamedClassInjectee.NAME);
		injector.injectInto(injectee);
		Assert.areEqual(value, injectee.property);
	}

	@Test
	public function bind_named_value_by_interface():Void
	{
		var injectee = new NamedInterfaceInjectee();
		var value = new Class1();

		injector.mapValue(Interface1, value, NamedClassInjectee.NAME);
		injector.injectInto(injectee);
		Assert.areEqual(value, injectee.property);
	}

	@Test
	public function bind_falsy_value():Void
	{
		var injectee = new StringInjectee();
		var value = "test";

		injector.mapValue(String, value);
		injector.injectInto(injectee);

		Assert.areEqual(value, injectee.property);
	}

	@Test
	public function bound_value_is_not_injected_into():Void
	{
		var injectee = new RecursiveInterfaceInjectee();
		var value = new InterfaceInjectee();

		injector.mapValue(InterfaceInjectee, value);
		injector.injectInto(injectee);

		Assert.isNull(value.property);
	}

	@Test
	public function bind_multiple_interfaces_to_one_singleton_class():Void
	{
		var injectee = new MultipleSingletonsOfSameClassInjectee();

		injector.mapSingletonOf(Interface1, Class1);
		injector.mapSingletonOf(Interface2, Class1);

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
		injector.mapClass(Class1, Class1);

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
		injector.mapClass(Class1, Class1);
		injector.mapClass(Class2, Class2);

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
		injector.mapClass(Typedef1, Typedef1);
		injector.mapClass(TypedefInjectee, TypedefInjectee);

		Assert.isTrue(injector.hasRule(Typedef1));
		Assert.isTrue(injector.hasRule(Class1));

		var injectee1 = new TypedefInjectee();
		injector.injectInto(injectee1);

		Assert.isNotNull(injectee1.property);
	}

	@Test
	public function bind_type_params():Void
	{
		// These 2 rules should match on the full type, so do not need a name.
		injector.mapValue("Array<String>", ["Jason","David"]);
		injector.mapValue("Array<Int>", [0,1,2]);
		// These 2 rules should match an Array with any type parameter - hence the need for names.
		injector.mapValue(Array, ["London","Sydney","Perth"], "cities");
		injector.mapValue(Array, [8416535,4840600,2021200], "populations");

		var injectee = new TypeParamInjectee();
		injector.injectInto(injectee);

		Assert.areEqual("Jason", injectee.names[0]);
		Assert.areEqual(0, injectee.numbers[0]);
		Assert.areEqual("London", injectee.cities[0]);
		Assert.areEqual(8416535, injectee.populations[0]);
	}

	@Test
	public function bound_class_is_injected_into():Void
	{
		var injectee = new ComplexClassInjectee();
		var value = new Class1();

		injector.mapValue(Class1, value);
		injector.mapClass(ComplexClass, ComplexClass);
		injector.injectInto(injectee);

		Assert.isNotNull(injectee.property);
		Assert.areEqual(value, injectee.property.value);
	}

	@Test
	public function bind_class_by_interface():Void
	{
		var injectee = new InterfaceInjectee();
		injector.mapClass(Interface1, Class1);
		injector.injectInto(injectee);
		Assert.isNotNull(injectee.property);
	}

	@Test
	public function bind_named_class():Void
	{
		var injectee:NamedClassInjectee = new NamedClassInjectee();
		injector.mapClass(Class1, Class1, NamedClassInjectee.NAME);
		injector.injectInto(injectee);
		Assert.isNotNull(injectee.property);
	}

	@Test
	public function bind_named_class_by_interface():Void
	{
		var injectee = new NamedInterfaceInjectee();
		injector.mapClass(Interface1, Class1, NamedClassInjectee.NAME);
		injector.injectInto(injectee);
		Assert.isNotNull(injectee.property);
	}

	@Test
	public function bind_singleton():Void
	{
		var injectee1:ClassInjectee = new ClassInjectee();
		var injectee2:ClassInjectee = new ClassInjectee();

		injector.mapSingleton(Class1);

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

		injector.mapSingletonOf(Interface1, Class1);

		injector.injectInto(injectee1);
		Assert.isNotNull(injectee1.property);

		injector.injectInto(injectee2);
		Assert.areEqual(injectee1.property, injectee2.property);
	}

	@Test
	public function bind_differently_named_singletons_by_same_interface():Void
	{
		var injectee = new TwoNamedInterfaceFieldsInjectee();

		injector.mapSingletonOf(Interface1, Class1, TwoNamedInterfaceFieldsInjectee.NAME1);
		injector.mapSingletonOf(Interface1, Class2, TwoNamedInterfaceFieldsInjectee.NAME2);

		injector.injectInto(injectee);

		Assert.isTrue(Std.is(injectee.property1, Class1));
		Assert.isTrue(Std.is(injectee.property2, Class2));
		Assert.isFalse(injectee.property1 == injectee.property2);
	}

	@Test
	public function perform_setter_injection():Void
	{
		var injectee1:SetterInjectee = new SetterInjectee();
		var injectee2:SetterInjectee = new SetterInjectee();

		injector.mapClass(Class1, Class1);

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

		injector.mapClass(Class1, Class1);

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

		injector.mapClass(Class1, Class1, OneNamedParameterMethodInjectee.NAME);

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

		injector.mapClass(Class1, Class1);
		injector.mapClass(Interface1, Class1);

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

		injector.mapClass(Class1, Class1, TwoNamedParametersMethodInjectee.NAME1);
		injector.mapClass(Interface1, Class1, TwoNamedParametersMethodInjectee.NAME2);

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

		injector.mapClass(Class1, Class1, MixedParametersMethodInjectee.NAME1);
		injector.mapClass(Class1, Class1);
		injector.mapClass(Interface1, Class1, MixedParametersMethodInjectee.NAME2);

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
		injector.mapClass(Class1, Class1);

		var injectee = injector.instantiate(OneParameterConstructorInjectee);
		Assert.isNotNull(injectee.getDependency());
	}

	@Test
	public function perform_constructor_injection_with_two_parameters():Void
	{
		injector.mapClass(Class1, Class1);
		injector.mapValue(String, "stringDependency");

		var injectee = injector.instantiate(TwoParametersConstructorInjectee);

		Assert.isNotNull(injectee.getDependency1());
		Assert.areEqual(injectee.getDependency2(), "stringDependency");
	}

	@Test
	public function perform_constructor_injection_with_one_named_parameter():Void
	{
		injector.mapClass(Class1, Class1, OneNamedParameterConstructorInjectee.NAME);
		var injectee = injector.instantiate(OneNamedParameterConstructorInjectee);
		Assert.isNotNull(injectee.getDependency());
	}

	@Test
	public function perform_constructor_injection_with_two_named_parameter():Void
	{
		var stringValue = "stringDependency";
		injector.mapClass(Class1, Class1, TwoNamedParametersConstructorInjectee.NAME1);
		injector.mapValue(String, stringValue, TwoNamedParametersConstructorInjectee.NAME2);

		var injectee = injector.instantiate(TwoNamedParametersConstructorInjectee);
		Assert.isNotNull(injectee.getDependency1());
		Assert.areEqual(injectee.getDependency2(), stringValue);
	}

	@Test
	public function perform_constructor_injection_with_mixed_parameters():Void
	{
		injector.mapClass(Class1, Class1, MixedParametersConstructorInjectee.NAME1);
		injector.mapClass(Class1, Class1);
		injector.mapClass(Interface1, Class1, MixedParametersConstructorInjectee.NAME2);

		var injectee = injector.instantiate(MixedParametersConstructorInjectee);
		Assert.isNotNull(injectee.getDependency1());
		Assert.isNotNull(injectee.getDependency2());
		Assert.isNotNull(injectee.getDependency3());
	}

	@Test
	public function perform_named_array_injection():Void
	{
		var array = ["value1", "value2", "value3"];

		injector.mapValue('Array<String>', array, NamedArrayInjectee.NAME);
		var injectee = injector.instantiate(NamedArrayInjectee);

		Assert.isNotNull(injectee.array);
		Assert.areEqual(array, injectee.array);
	}

	@Test
	public function perform_mapped_rule_injection():Void
	{
		var rule = injector.mapSingletonOf(Interface1, Class1);
		injector.mapRule(Interface2, rule);

		var injectee = injector.instantiate(MultipleSingletonsOfSameClassInjectee);
		Assert.areEqual(injectee.property1, injectee.property2);
	}

	@Test
	public function perform_mapped_named_rule_injection():Void
	{
		var rule = injector.mapSingletonOf(Interface1, Class1);

		injector.mapRule(Interface2, rule);
		injector.mapRule(Interface1, rule, MultipleNamedSingletonsOfSameClassInjectee.NAME1);
		injector.mapRule(Interface2, rule, MultipleNamedSingletonsOfSameClassInjectee.NAME2);

		var injectee = injector.instantiate(MultipleNamedSingletonsOfSameClassInjectee);
		Assert.areEqual(injectee.property1, injectee.property2);
		Assert.areEqual(injectee.property1, injectee.namedProperty1);
		Assert.areEqual(injectee.property1, injectee.namedProperty2);
	}

	@Test
	public function perform_injection_into_value_with_recursive_singelton_dependency():Void
	{
		var injectee = new InterfaceInjectee();

		injector.mapValue(InterfaceInjectee, injectee);
		injector.mapSingletonOf(Interface1, RecursiveInterfaceInjectee);

		injector.injectInto(injectee);
		Assert.isTrue(true);
	}

	@Test
	public function inject_x_m_l_value() : Void
	{
		var injectee = new XMLInjectee();
		var value = Xml.parse("<test/>");

		injector.mapValue(Xml, value);
		injector.injectInto(injectee);

		Assert.areEqual(injectee.property, value);
	}

	@Test
	public function post_construct_is_called():Void
	{
		var injectee = new ClassInjectee();
		var value = new Class1();

		injector.mapValue(Class1, value);
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
	public function has_rule_fails_for_unmapped_unnamed_class():Void
	{
		Assert.isFalse(injector.hasRule(Class1));
	}

	@Test
	public function has_rule_fails_for_unmapped_named_class():Void
	{
		Assert.isFalse(injector.hasRule(Class1, "namedClass"));
	}

	@Test
	public function has_rule_succeeds_for_mapped_unnamed_class():Void
	{
		injector.mapClass(Class1, Class1);
		Assert.isTrue(injector.hasRule(Class1));
	}

	@Test
	public function has_rule_succeeds_for_mapped_named_class():Void
	{
		injector.mapClass(Class1, Class1, "namedClass");
		Assert.isTrue(injector.hasRule(Class1, "namedClass"));
	}

	@Test
	public function get_rule_response_succeeds_for_mapped_unnamed_class():Void
	{
		var class1 = new Class1();
		injector.mapValue(Class1, class1);
		Assert.areEqual(injector.getInstance(Class1), class1);
	}

	@Test
	public function get_rule_response_succeeds_for_mapped_named_class():Void
	{
		var class1 = new Class1();
		injector.mapValue(Class1, class1, "namedClass");
		Assert.areEqual(injector.getInstance(Class1, "namedClass"), class1);
	}

	@Test
	public function injector_removes_singleton_instance_on_rule_removal():Void
	{
		injector.mapSingleton(Class1);

		var injectee1 = injector.instantiate(ClassInjectee);
		injector.unmap(Class1);
		injector.mapSingleton(Class1);

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
	public function get_rule_response_fails_for_unmapped_unnamed_class():Void
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
	public function get_rule_response_fails_for_unmapped_named_class():Void
	{
		var passed = false;

		try
		{
			injector.getInstance(Class1, "namedClass");
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
		injector.mapSingleton(RecursiveInjectee1);
		injector.mapSingleton(RecursiveInjectee2);
		injector.instantiate(RecursiveInjectee1);
	}

	@Test
	public function should_get_response()
	{
		injector.mapValue(Int, 10, 'sessionExpiry');
		var value = injector.getResponse(Int, 'sessionExpiry');
		Assert.areEqual(10, value);
	}
}
