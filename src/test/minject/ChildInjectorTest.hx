// See the file "LICENSE" for the full license governing this code

package minject;

import massive.munit.Assert;
import minject.support.injectees.ClassInjectee;
import minject.support.injectees.childinjectors.*;
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
	public function injector_uses_child_injector_for_specified_mapping():Void
	{
		injector.map(RobotFoot).toClass(RobotFoot);
		injector.map(RobotToes).toClass(RobotToes);

		var leftFootRule = injector.map(RobotLeg, 'leftLeg').toClass(RobotLeg);
		var leftChildInjector = injector.createChildInjector();
		leftChildInjector.map(RobotAnkle).toClass(RobotAnkle);
		leftChildInjector.map(RobotFoot).toClass(LeftRobotFoot);
		leftFootRule.injector = leftChildInjector;

		var rightFootRule = injector.map(RobotLeg, 'rightLeg').toClass(RobotLeg);
		var rightChildInjector = injector.createChildInjector();
		rightChildInjector.map(RobotAnkle).toClass(RobotAnkle);
		rightChildInjector.map(RobotFoot).toClass(RightRobotFoot);
		rightFootRule.injector = rightChildInjector;

		var robotBody = injector.instantiate(RobotBody);
		Assert.isType(robotBody.rightLeg.ankle.foot, RightRobotFoot);
		Assert.isType(robotBody.leftLeg.ankle.foot, LeftRobotFoot);
	}

	@Test
	public function child_injector_uses_parent_injector_for_missing_mappings():Void
	{
		injector.map(RobotFoot).toClass(RobotFoot);
		injector.map(RobotToes).toClass(RobotToes);

		var leftFootRule = injector.map(RobotLeg, 'leftLeg').toClass(RobotLeg);
		var leftChildInjector = injector.createChildInjector();
		leftChildInjector.map(RobotAnkle).toClass(RobotAnkle);
		leftChildInjector.map(RobotFoot).toClass(LeftRobotFoot);
		leftFootRule.injector = leftChildInjector;

		var rightFootRule = injector.map(RobotLeg, 'rightLeg').toClass(RobotLeg);
		var rightChildInjector = injector.createChildInjector();
		rightChildInjector.map(RobotAnkle).toClass(RobotAnkle);
		rightChildInjector.map(RobotFoot).toClass(RightRobotFoot);
		rightFootRule.injector = rightChildInjector;

		var robotBody = injector.instantiate(RobotBody);

		Assert.isType(robotBody.rightLeg.ankle.foot.toes, RobotToes);
		Assert.isType(robotBody.leftLeg.ankle.foot.toes, RobotToes);
	}

	@Test
	public function child_injector_doesnt_return_to_parent_after_using_parent_injector_for_missing_mappings():Void
	{
		injector.map(RobotAnkle).toClass(RobotAnkle);
		injector.map(RobotFoot).toClass(RobotFoot);
		injector.map(RobotToes).toClass(RobotToes);

		var leftFootRule = injector.map(RobotLeg, 'leftLeg').toClass(RobotLeg);
		var leftChildInjector = injector.createChildInjector();
		leftChildInjector.map(RobotFoot).toClass(LeftRobotFoot);
		leftFootRule.injector = leftChildInjector;

		var rightFootRule = injector.map(RobotLeg, 'rightLeg').toClass(RobotLeg);
		var rightChildInjector = injector.createChildInjector();
		rightChildInjector.map(RobotFoot).toClass(RightRobotFoot);
		rightFootRule.injector = rightChildInjector;

		var robotBody = injector.instantiate(RobotBody);
		Assert.isType(robotBody.rightLeg.ankle.foot, RightRobotFoot);
		Assert.isType(robotBody.leftLeg.ankle.foot, LeftRobotFoot);
	}

	@Test
	public function child_injector_has_mapping_when_exists_on_parent_injector():Void
	{
		var childInjector = injector.createChildInjector();
		injector.map(Class1).toValue(new Class1());

		Assert.isTrue(childInjector.hasMapping(Class1));
	}

	@Test
	@:access(minject.Injector)
	public function child_injector_get_response_does_not_break_mapping_when_when_exists_on_parent_injector():Void
	{
		var childInjector = injector.createChildInjector();
		var class1 = new Class1();
		injector.map(Class1).toValue(class1);

		Assert.areEqual(1, Lambda.count(injector.mappings));
		Assert.areEqual(0, Lambda.count(childInjector.mappings));

		var response1 = childInjector.getValue(Class1);
		var response2 = childInjector.getInstance(Class1);
		Assert.areEqual(class1, response1);
		Assert.areEqual(class1, response2);

		Assert.areEqual(1, Lambda.count(injector.mappings));
		Assert.areEqual(0, Lambda.count(childInjector.mappings));
	}

	@Test
	public function child_injector_does_not_have_mapping_when_does_not_exist_on_parent_injector():Void
	{
		var childInjector = injector.createChildInjector();
		Assert.isFalse(childInjector.hasMapping(Class1));
	}

	@Test
	public function grand_child_injector_supplies_injection_from_ancestor():Void
	{
		var injectee = new ClassInjectee();
		var childInjector = injector.createChildInjector();
		var grandChildInjector = childInjector.createChildInjector();

		injector.map(Class1).asSingleton();
		grandChildInjector.injectInto(injectee);

		Assert.isType(injectee.property, Class1);
	}

	@Test
	public function can_create_child_injector_during_injection():Void
	{
		injector.map(Injector).toMapping(new InjectorCopyRule());
		injector.map(InjectorInjectee).toClass(InjectorInjectee);
		var injectee = injector.getInstance(InjectorInjectee);

		Assert.isNotNull(injectee.injector);
		Assert.isTrue(injectee.injector.parent == injector);
		Assert.isTrue(injectee.nestedInjectee.nestedInjectee.injector.parent.parent.parent == injector);
	}
}
