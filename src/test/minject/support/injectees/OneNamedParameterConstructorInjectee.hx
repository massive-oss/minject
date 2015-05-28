// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class OneNamedParameterConstructorInjectee
{
	public static var NAME = 'name';

	var dependency:Class1;

	public function getDependency():Class1
	{
		return dependency;
	}

	@inject('name')
	public function new(dependency:Class1)
	{
		this.dependency = dependency;
	}
}
