// See the file "LICENSE" for the full license governing this code

package minject.support.types;

class Class1Extension extends Class1
{
	// the test using the class is a bit contrived, hence the @:keep
	@:keep public function new()
	{
		super();
	}
}
