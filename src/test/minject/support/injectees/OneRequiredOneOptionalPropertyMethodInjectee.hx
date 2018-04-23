// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;
import minject.support.types.Interface1;

class OneRequiredOneOptionalPropertyMethodInjectee
{
	var dependency1:Class1;
	var dependency2:Interface1;

	public function new(){}

	@inject
	public function setDependencies(dependency1:Class1, ?dependency2:Interface1=null):Void
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
}
