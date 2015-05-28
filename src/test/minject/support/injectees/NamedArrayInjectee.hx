// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

class NamedArrayInjectee
 {
	public static var NAME = 'name';

	@inject('name')
	public var array:Array<String>;

	public function new(){}
}
