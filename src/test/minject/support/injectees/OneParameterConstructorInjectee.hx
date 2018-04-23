// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class OneParameterConstructorInjectee
{
	var dependency:Class1;

	public function getDependency():Class1
	{
		return dependency;
	}

	@inject
	public function new(dependency:Class1)
	{
		this.dependency = dependency;
	}
}
