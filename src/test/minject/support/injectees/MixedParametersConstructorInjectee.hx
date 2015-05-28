// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;
import minject.support.types.Interface1;

class MixedParametersConstructorInjectee
{
	public static var NAME1 = 'name1';
	public static var NAME2 = 'name2';

	var dependency1:Class1;
	var dependency2:Class1;
	var dependency3:Interface1;

	public function getDependency1():Class1
	{
		return dependency1;
	}
	public function getDependency2():Class1
	{
		return dependency2;
	}
	public function getDependency3():Interface1
	{
		return dependency3;
	}

	@inject('name1', '', 'name2')
	public function new(dependency1:Class1, dependency2:Class1, dependency3:Interface1)
	{
		this.dependency1 = dependency1;
		this.dependency2 = dependency2;
		this.dependency3 = dependency3;
	}
}
