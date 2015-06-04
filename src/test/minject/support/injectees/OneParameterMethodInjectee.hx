// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class OneParameterMethodInjectee
{
	var dependency:Class1;

	@inject
	public function setDependency(dependency:Class1):Void
	{
		this.dependency = dependency;
	}

	public function getDependency():Class1
	{
		return dependency;
	}

	public function new(){}
}
