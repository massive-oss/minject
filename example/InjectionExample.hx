import minject.Injector;

class InjectionExample
{
	public static function main()
	{
		new InjectionExample();
	}

	public var injector:Injector;

	public function new()
	{
		injector = new Injector();

		initializeContext();

		var foo = new Foo();
		injector.injectInto(foo);

		trace(foo);
		trace(foo.cb());
	}

	/**
		Registers three class types using three approaches
			- singleton
			- class (with name)
			- value (with name);
	**/
	function initializeContext()
	{
		injector.mapSingleton(TypeA);
		injector.mapClass(TypeB, TypeB, "foo");
		injector.mapTypeValue('Void -> String', function () return 'Hello!');

		var a = injector.getInstance(TypeA);
		a.id = 123;

		var c = new TypeC();
		c.id = 666;

		injector.mapValue(TypeB, c, "bar");
	}
}

class Foo
{
	@inject
	public var a:TypeA;

	@inject("foo")
	public var b:TypeB;

	@inject("bar")
	public var c:TypeB;

	@inject
	public var cb:Void -> String;

	@inject public var array:Array<Int>;
	@inject public var int:Int;
    @inject public var iter:Iterable<Int>;
    @inject public var enumValue:Type.ValueType;
    @inject public var fn:String->String->Bool;
    @inject public var flags:haxe.EnumFlags<Type.ValueType>;

	public function new(){}

	public function toString():String
	{
		return 'Foo\n	a: $a\n	b: $b\n	c: $c';
	}
}

class TypeA
{
	public var id:Int;

	public function new()
	{
		id = 0;
	}

	public function toString():String
	{
		return 'TypeA $id';
	}
}

class TypeB
{
	public var id:Int;

	public function new()
	{
		id = 0;
	}

	public function toString():String
	{
		return 'TypeB $id';
	}
}

class TypeC extends TypeB
{
	public function new()
	{
		super();
	}

	override public function toString():String
	{
		return 'TypeC $id';
	}
}
