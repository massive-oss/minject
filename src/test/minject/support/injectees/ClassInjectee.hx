// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class ClassInjectee
{
	@inject
	public var property:Class1;

	public var someProperty:Bool;

	public function new()
	{
		someProperty = false;
	}

	@post(1)
	public function doSomeStuff():Void
	{
		someProperty = true;
	}
}
