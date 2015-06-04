// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class AnonTypedefInjectee
{
	@inject
	public var property:Greeter;

	public function new()
	{
	}

	@post(1)
	public function sayHi():Void
	{
		trace(property.hello(property.name));
	}

}

typedef Greeter = {
	var name:String;
	public function hello(name:String):String;
};
