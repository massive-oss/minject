// See the file "LICENSE" for the full license governing this code

package minject.support.injectees;

import minject.support.types.Class1;

class TypeParamInjectee
{
	@inject
	public var names:Array<String>;

	@inject
	public var numbers:Array<Int>;

	@inject('cities')
	public var cities:Array<String>;

	@inject('populations')
	public var populations:Array<Int>;

	@inject('','','cities','populations')
	public function testMethodInjection(names:Array<String>, numbers:Array<Int>, cities:Array<String>, populations:Array<Int>) {
		// Just test that no exception is thrown.
	}

	public function new() {}
}
