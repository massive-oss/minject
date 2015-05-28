// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class TwoOptionalParametersConstructorInjectee
{
	var dependency1:Class1;
	var dependency2:String;

	public function getDependency():Class1
	{
		return dependency1;
	}
	public function getDependency2():String
	{
		return dependency2;
	}

	public function new(?dependency1:Class1=null, ?dependency2:String=null)
	{
		this.dependency1 = dependency1;
		this.dependency2 = dependency2;
	}
}
