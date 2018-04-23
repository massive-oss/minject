// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class SetterInjectee
{
	// NOTE: this needs private storage to confirm haxe isn't simply setting
	// the property directly, bypassing the setter.

	@inject
	public var property(get, set):Class1;

	var _property:Class1;

	public function set_property(value:Class1):Class1
	{
		_property = value;
		return value;
	}

	public function get_property():Class1
	{
		return _property;
	}

	public function new(){}
}
