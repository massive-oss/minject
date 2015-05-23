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
import minject.support.injectees.ClassInjectee;
import minject.support.injectees.childinjectors.InjectorCopyRule;
import minject.support.injectees.childinjectors.InjectorInjectee;
import minject.support.injectees.childinjectors.LeftRobotFoot;
import minject.support.injectees.childinjectors.RightRobotFoot;
import minject.support.injectees.childinjectors.RobotAnkle;
import minject.support.injectees.childinjectors.RobotBody;
import minject.support.injectees.childinjectors.RobotFoot;
import minject.support.injectees.childinjectors.RobotLeg;
import minject.support.injectees.childinjectors.RobotToes;
import minject.support.types.Class1;

@:keep class ChildInjectorTest
 {
	public function new(){}

	var injector:Injector;

	@Before
	public function runBeforeEachTest():Void
	{
		injector = new Injector();
	}

	@After
	public function teardown():Void
	{
		injector = null;
	}

	@Test
	public function injector_creates_child_injector():Void
	{
		var childInjector = injector.createChildInjector();
		Assert.isType(childInjector, Injector);
	}

	@Test
	public function injector_uses_child_injector_for_specified_rule():Void
	{
		injector.mapClass(RobotFoot, RobotFoot);
		injector.mapClass(RobotToes, RobotToes);

		var leftFootRule = injector.mapClass(RobotLeg, RobotLeg, "leftLeg");
		var leftChildInjector = injector.createChildInjector();
		leftChildInjector.mapClass(RobotAnkle, RobotAnkle);
		leftChildInjector.mapClass(RobotFoot, LeftRobotFoot);
		leftFootRule.injector = leftChildInjector;

		var rightFootRule = injector.mapClass(RobotLeg, RobotLeg, "rightLeg");
		var rightChildInjector = injector.createChildInjector();
		rightChildInjector.mapClass(RobotAnkle, RobotAnkle);
		rightChildInjector.mapClass(RobotFoot, RightRobotFoot);
		rightFootRule.injector = rightChildInjector;

		var robotBody = injector.instantiate(RobotBody);
		Assert.isType(robotBody.rightLeg.ankle.foot, RightRobotFoot);
		Assert.isType(robotBody.leftLeg.ankle.foot, LeftRobotFoot);
	}

	@Test
	public function child_injector_uses_parent_injector_for_missing_rules():Void
	{
		injector.mapClass(RobotFoot, RobotFoot);
		injector.mapClass(RobotToes, RobotToes);

		var leftFootRule = injector.mapClass(RobotLeg, RobotLeg, "leftLeg");
		var leftChildInjector = injector.createChildInjector();
		leftChildInjector.mapClass(RobotAnkle, RobotAnkle);
		leftChildInjector.mapClass(RobotFoot, LeftRobotFoot);
		leftFootRule.injector = leftChildInjector;

		var rightFootRule = injector.mapClass(RobotLeg, RobotLeg, "rightLeg");
		var rightChildInjector = injector.createChildInjector();
		rightChildInjector.mapClass(RobotAnkle, RobotAnkle);
		rightChildInjector.mapClass(RobotFoot, RightRobotFoot);
		rightFootRule.injector = rightChildInjector;

		var robotBody = injector.instantiate(RobotBody);

		Assert.isType(robotBody.rightLeg.ankle.foot.toes, RobotToes);
		Assert.isType(robotBody.leftLeg.ankle.foot.toes, RobotToes);
	}

	@Test
	public function child_injector_doesnt_return_to_parent_after_using_parent_injector_for_missing_rules():Void
	{
		injector.mapClass(RobotAnkle, RobotAnkle);
		injector.mapClass(RobotFoot, RobotFoot);
		injector.mapClass(RobotToes, RobotToes);

		var leftFootRule = injector.mapClass(RobotLeg, RobotLeg, "leftLeg");
		var leftChildInjector = injector.createChildInjector();
		leftChildInjector.mapClass(RobotFoot, LeftRobotFoot);
		leftFootRule.injector = leftChildInjector;

		var rightFootRule = injector.mapClass(RobotLeg, RobotLeg, "rightLeg");
		var rightChildInjector = injector.createChildInjector();
		rightChildInjector.mapClass(RobotFoot, RightRobotFoot);
		rightFootRule.injector = rightChildInjector;

		var robotBody = injector.instantiate(RobotBody);
		Assert.isType(robotBody.rightLeg.ankle.foot, RightRobotFoot);
		Assert.isType(robotBody.leftLeg.ankle.foot, LeftRobotFoot);
	}

	@Test
	public function child_injector_has_mapping_when_exists_on_parent_injector():Void
	{
		var childInjector = injector.createChildInjector();
		var class1 = new Class1();
		injector.mapValue(Class1, class1);

		Assert.isTrue(childInjector.hasRule(Class1));
	}

	@Test
	@:access(minject.Injector)
	public function child_injector_get_response_does_not_break_mapping_when_when_exists_on_parent_injector():Void
	{
		var childInjector = injector.createChildInjector();
		var class1 = new Class1();
		injector.mapValue(Class1, class1);

		Assert.areEqual(1, Lambda.count(injector.rules));
		Assert.areEqual(0, Lambda.count(childInjector.rules));

		var response1 = childInjector.getResponse(Class1);
		var response2 = childInjector.getInstance(Class1);
		Assert.areEqual( class1, response1 );
		Assert.areEqual( class1, response2 );

		Assert.areEqual(1, Lambda.count(injector.rules));
		Assert.areEqual(0, Lambda.count(childInjector.rules));
	}

	@Test
	public function child_injector_does_not_have_mapping_when_does_not_exist_on_parent_injector():Void
	{
		var childInjector = injector.createChildInjector();
		Assert.isFalse(childInjector.hasRule(Class1));
	}

	@Test
	public function grand_child_injector_supplies_injection_from_ancestor():Void
	{
		var injectee = new ClassInjectee();
		var childInjector = injector.createChildInjector();
		var grandChildInjector = childInjector.createChildInjector();

		injector.mapSingleton(Class1);
		grandChildInjector.injectInto(injectee);

		Assert.isType(injectee.property, Class1);
	}

	@Test
	public function can_create_child_injector_during_injection():Void
	{
		injector.mapRule(Injector, new InjectorCopyRule());
		injector.mapClass(InjectorInjectee, InjectorInjectee);
		var injectee = injector.getInstance(InjectorInjectee);

		Assert.isNotNull(injectee.injector);
		Assert.isTrue(injectee.injector.parent == injector);
		Assert.isTrue(injectee.nestedInjectee.nestedInjectee.injector.parent.parent.parent == injector);
	}
}
