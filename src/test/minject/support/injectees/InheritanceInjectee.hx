// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;
import minject.support.types.Class2;

class InheritanceInjectee extends ClassInjectee
{
	@inject
	public var property2:Class2;

	public var extraProperty:Bool;

	public function new()
	{
		super();
		extraProperty = false;
	}

	@post(2)
	public function doExtraStuff():Void
	{
		extraProperty = true;
	}
}
