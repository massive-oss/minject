// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class OneNamedParameterMethodInjectee
{
	public static var NAME = 'name';

	var dependency:Class1;

	@inject('name')
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
