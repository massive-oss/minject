// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class AnonTypedefInjectee
{
	@inject
	public var property:Greeter;

	public function new() {}
}

typedef Greeter = {
	var name:String;
	public function hello(name:String):String;
};
