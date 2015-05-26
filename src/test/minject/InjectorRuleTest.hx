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

import minject.result.InjectClassResult;
import minject.result.InjectOtherRuleResult;
import minject.result.InjectSingletonResult;
import minject.result.InjectValueResult;
import minject.support.types.Class1;
import minject.support.types.Class1Extension;

@:keep class InjectorRuleTest
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
	public function rule_is_instantiated():Void
	{
		var rule = new InjectorRule('minject.support.types.Class1', '');
		Assert.isTrue(Std.is(rule, InjectorRule));
	}

	@Test
	public function injection_type_value_returns_respone():Void
	{
		var response = new Class1();
		var rule = new InjectorRule('minject.support.types.Class1', '');
		rule.setResult(new InjectValueResult(response));
		var returnedResponse = rule.getResponse(injector);

		Assert.areEqual(response, returnedResponse);
	}

	@Test
	public function injection_type_class_returns_respone():Void
	{
		var rule = new InjectorRule('minject.support.types.Class1', '');
		rule.setResult(new InjectClassResult(Class1));
		var returnedResponse = rule.getResponse(injector);

		Assert.isTrue(Std.is(returnedResponse, Class1));
	}

	@Test
	public function injection_type_singleton_returns_response():Void
	{
		var rule = new InjectorRule('minject.support.types.Class1', '');
		rule.setResult(new InjectSingletonResult(Class1));
		var returnedResponse = rule.getResponse(injector);

		Assert.isTrue(Std.is(returnedResponse, Class1));
	}

	@Test
	public function same_singleton_is_returned_on_second_response():Void
	{
		var rule = new InjectorRule('minject.support.types.Class1', '');
		rule.setResult(new InjectSingletonResult(Class1));
		var returnedResponse = rule.getResponse(injector);
		var secondResponse = rule.getResponse(injector);

		Assert.areEqual(returnedResponse, secondResponse);
	}

	@Test
	public function same_named_singleton_is_returned_on_second_response():Void
	{
		var rule = new InjectorRule('minject.support.types.Class1', "named");
		rule.setResult(new InjectSingletonResult(Class1));
		var returnedResponse = rule.getResponse(injector);
		var secondResponse = rule.getResponse(injector);

		Assert.areEqual(returnedResponse, secondResponse);
	}

	@Test
	public function calling_set_result_between_usages_changes_response():Void
	{
		var rule = new InjectorRule('minject.support.types.Class1', '');
		rule.setResult(new InjectSingletonResult(Class1));
		var returnedResponse = rule.getResponse(injector);
		rule.setResult(null);
		rule.setResult(new InjectClassResult(Class1));
		var secondResponse = rule.getResponse(injector);

		Assert.isFalse(returnedResponse == secondResponse);
	}

	@Test
	public function injection_type_other_rule_returns_other_rules_response():Void
	{
		var rule = new InjectorRule('minject.support.types.Class1', '');
		var otherConfig = new InjectorRule('minject.support.types.Class1Extension', '');
		otherConfig.setResult(new InjectClassResult(Class1Extension));
		rule.setResult(new InjectOtherRuleResult(otherConfig));
		var returnedResponse = rule.getResponse(injector);

		Assert.isTrue(Std.is(returnedResponse, Class1));
		Assert.isTrue(Std.is(returnedResponse, Class1Extension));
	}
}
