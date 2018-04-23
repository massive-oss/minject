package minject.support.injectees;

class RecursiveInjectee1
{
	@inject public var property:RecursiveInjectee2;

	public function new() {}
}

class RecursiveInjectee2
{
	@inject public var property:RecursiveInjectee1;

	public function new() {}
}
