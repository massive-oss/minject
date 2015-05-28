// See the file "LICENSE" for the full license governing this code

import minject.Injector;
import Type;

class InjectionExample
{
	public static function main()
	{
		var injector = new Injector();

		injector.map(TypeA).asSingleton();
		injector.map(TypeB, "foo").toClass(TypeB);
		injector.map(Int).toValue(20);
		injector.map(ValueType).toValue(TObject);
		injector.map('Void -> String').toValue(function () return 'Hello!');
		injector.map('Array<Int>').toValue([0,1,2]);
		injector.map('Iterable<Int>').toValue([0,1,2]);
		injector.map('String -> String -> Bool').toValue(function(a, b) return a == b);
		injector.map('haxe.EnumFlags<ValueType>').toValue(new haxe.EnumFlags<ValueType>());

		var a = injector.getInstance(TypeA);
		a.id = 123;

		var c = new TypeC();
		c.id = 666;

		injector.map(TypeB, "bar").toValue(c);

		var foo = new Foo();
		injector.injectInto(foo);

		trace('foo.a ${foo.a}');
		trace('foo.b ${foo.b}');
		trace('foo.c ${foo.c}');

		trace('foo.cb() ${foo.cb()}');
		trace('foo.fn() ${foo.fn("a", "b")}');

		trace('foo.integer ${foo.integer}');
		trace('foo.array ${foo.array}');
		trace('foo.iter ${foo.iter}');
		trace('foo.enumValue ${foo.enumValue}');
		trace('foo.flags ${foo.flags}');

		// trace(minject.Injector.getExprTypeId(function () return ''));
	}
}

class Foo
{
	@inject public var a:TypeA;
	@inject("foo") public var b:TypeB;
	@inject("bar") public var c:TypeB;
	@inject public var cb:Void -> String;
	@inject public var fn:String -> String -> Bool;
	@inject public var integer:Int;
	@inject public var array:Array<Int>;
    @inject public var iter:Iterable<Int>;
    @inject public var enumValue:ValueType;
    @inject public var flags:haxe.EnumFlags<Type.ValueType>;

	public function new(){}
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
