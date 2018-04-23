// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;
import minject.support.types.Interface1;

class TwoNamedParametersMethodInjectee
{
	public static var NAME1 = 'name1';
	public static var NAME2 = 'name2';

	var dependency1:Class1;
	var dependency2:Interface1;

	@inject('name1', 'name2')
	public function setDependencies(dependency1:Class1, dependency2:Interface1):Void
	{
		this.dependency1 = dependency1;
		this.dependency2 = dependency2;
	}
	public function getDependency1():Class1
	{
		return dependency1;
	}

	public function getDependency2():Interface1
	{
		return dependency2;
	}

	public function new(){}
}
