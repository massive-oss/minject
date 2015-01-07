/*
Copyright (c) 2012-2014 Massive Interactive

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

import minject.support.types.Class1Extension;
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

class ChildInjectorTest
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
	public function injectorCreatesChildInjector():Void
	{
		var childInjector = injector.createChildInjector();
		Assert.isType(childInjector, Injector);
	}

	@Test
	public function injectorUsesChildInjectorForSpecifiedRule():Void
	{
		injector.mapClass(RobotFoot, RobotFoot);

		var leftFootRule = injector.mapClass(RobotLeg, RobotLeg, "leftLeg");
		var leftChildInjector = injector.createChildInjector();
		leftChildInjector.mapClass(RobotAnkle, RobotAnkle);
		leftChildInjector.mapClass(RobotFoot, LeftRobotFoot);
		leftFootRule.setInjector(leftChildInjector);

		var rightFootRule = injector.mapClass(RobotLeg, RobotLeg, "rightLeg");
		var rightChildInjector = injector.createChildInjector();
		rightChildInjector.mapClass(RobotAnkle, RobotAnkle);
		rightChildInjector.mapClass(RobotFoot, RightRobotFoot);
		rightFootRule.setInjector(rightChildInjector);

		var robotBody = injector.instantiate(RobotBody);
		Assert.isType(robotBody.rightLeg.ankle.foot, RightRobotFoot);
		Assert.isType(robotBody.leftLeg.ankle.foot, LeftRobotFoot);
	}

	@Test
	public function childInjectorUsesParentInjectorForMissingRules():Void
	{
		injector.mapClass(RobotFoot, RobotFoot);
		injector.mapClass(RobotToes, RobotToes);

		var leftFootRule = injector.mapClass(RobotLeg, RobotLeg, "leftLeg");
		var leftChildInjector = injector.createChildInjector();
		leftChildInjector.mapClass(RobotAnkle, RobotAnkle);
		leftChildInjector.mapClass(RobotFoot, LeftRobotFoot);
		leftFootRule.setInjector(leftChildInjector);

		var rightFootRule = injector.mapClass(RobotLeg, RobotLeg, "rightLeg");
		var rightChildInjector = injector.createChildInjector();
		rightChildInjector.mapClass(RobotAnkle, RobotAnkle);
		rightChildInjector.mapClass(RobotFoot, RightRobotFoot);
		rightFootRule.setInjector(rightChildInjector);

		var robotBody = injector.instantiate(RobotBody);

		Assert.isType(robotBody.rightLeg.ankle.foot.toes, RobotToes);
		Assert.isType(robotBody.leftLeg.ankle.foot.toes, RobotToes);
	}

	@Test
	public function childInjectorDoesntReturnToParentAfterUsingParentInjectorForMissingRules():Void
	{
		injector.mapClass(RobotAnkle, RobotAnkle);
		injector.mapClass(RobotFoot, RobotFoot);
		injector.mapClass(RobotToes, RobotToes);

		var leftFootRule = injector.mapClass(RobotLeg, RobotLeg, "leftLeg");
		var leftChildInjector = injector.createChildInjector();
		leftChildInjector.mapClass(RobotFoot, LeftRobotFoot);
		leftFootRule.setInjector(leftChildInjector);

		var rightFootRule = injector.mapClass(RobotLeg, RobotLeg, "rightLeg");
		var rightChildInjector = injector.createChildInjector();
		rightChildInjector.mapClass(RobotFoot, RightRobotFoot);
		rightFootRule.setInjector(rightChildInjector);

		var robotBody = injector.instantiate(RobotBody);
		Assert.isType(robotBody.rightLeg.ankle.foot, RightRobotFoot);
		Assert.isType(robotBody.leftLeg.ankle.foot, LeftRobotFoot);
	}

    @Test
    public function childInjectorHasMappingWhenExistsOnParentInjectorUsingParentSetter():Void
    {
        var childInjector = new Injector();
        childInjector.parentInjector = injector;
        var class1 = new Class1();
        injector.mapValue(Class1, class1);

        Assert.isTrue(childInjector.hasMapping(Class1));
    }

    @Test
    public function existingConfigsshouldNotOverwriteAlreadyMappedChildConfigs():Void {
        var childInjector = new Injector();
        childInjector.mapClass(Class1, Class1Extension);
        injector.mapValue(Class1, Class1);
        childInjector.parentInjector = injector;

        Assert.isTrue(Std.is(childInjector.getInstance(Class1), Class1Extension));
    }

    @Test
    public function childInjectorHasMappingWhenExistsOnParentInjector():Void
    {
        var childInjector = injector.createChildInjector();
        var class1 = new Class1();
        injector.mapValue(Class1, class1);

        Assert.isTrue(childInjector.hasMapping(Class1));
    }

    @Test
    public function childInjectorDoesNotHaveMappingWhenDoesNotExistOnParentInjector():Void
    {
        var childInjector = injector.createChildInjector();
        Assert.isFalse(childInjector.hasMapping(Class1));
    }

    @Test
    public function grandChildInjectorSuppliesInjectionFromAncestor():Void
    {
        var injectee = new ClassInjectee();
        var childInjector = injector.createChildInjector();
        var grandChildInjector = childInjector.createChildInjector();

        injector.mapSingleton(Class1);
        grandChildInjector.injectInto(injectee);

        Assert.isType(injectee.property, Class1);
    }

	@Test
	public function injectorCanCreateChildInjectorDuringInjection():Void
	{
		injector.mapRule(Injector, new InjectorCopyRule());
		injector.mapClass(InjectorInjectee, InjectorInjectee);
		var injectee = injector.getInstance(InjectorInjectee);

		Assert.isNotNull(injectee.injector);
		Assert.isTrue(injectee.injector.parentInjector == injector);
		Assert.isTrue(injectee.nestedInjectee.nestedInjectee.injector.parentInjector.parentInjector.parentInjector == injector);
	}
}
