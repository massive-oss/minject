// See the file "LICENSE" for the full license governing this code

package minject;

import haxe.rtti.Meta;
import haxe.macro.Expr;
import haxe.ds.ArraySort;

import minject.point.*;
import minject.provider.*;

/**
	The dependency injector
**/
#if !macro @:build(minject.InjectorMacro.addMetadata()) #end
class Injector
{
	public static function getValueType(value:Dynamic):String
	{
		if (Std.is(value, String))
			return 'String';
		if (Std.is(value, Class))
			return Type.getClassName(value);
		if (Std.is(value, Enum))
			return Type.getEnumName(value);
		var name = switch (Type.typeof(value))
		{
			case TInt: 'Int';
			case TBool: 'Bool';
			case TClass(c): Type.getClassName(c);
			case TEnum(e): Type.getEnumName(e);
			default: null;
		}
		if (name != null) return name;
		throw 'Could not determine type name of $value';
	}

	/**
		The parent of this injector
	**/
	public var parent(default, null):Injector;

	// map of injector mappings by type#name
	var mappings = new Map<String, InjectorMapping<Dynamic>>();

	// map of injector infos by type
	var infos = new Map<String, InjectorInfo>();

	public function new(?parent:Injector)
	{
		this.parent = parent;
	}

	//-------------------------------------------------------------------------- mapping

	/**
		Returns an `InjectorMapping` for `type` with optional `name`

		This macro method determines the string identifier for the type, and adds `@:keep` metadata
		to ensure the type is not eliminated by dead code elimination.

		The method returns an `InjectorMapping` with no provider set. A provider should be set by
		a chained call to the mappings provider methods.

		```haxe
		var injector = new Injector();
		injector.map(Int).toValue(10);
		injector.map(MyInterface).toClass(MyImplementor);
		injector.map(MySingleton).asSingleton();

		@param type The type to map
		@param name The optional name for the mapping
		```
	**/
	public macro function map(ethis:Expr, type:Expr, ?name:Expr):Expr
	{
		// ensure type does not get eleminated by dce
		InjectorMacro.keep(type);

		// get type identifier
		var id = InjectorMacro.getExprType(type);

		// get value type
		var type = InjectorMacro.getValueType(type);

		// forward to runtime method
		return macro @:pos(ethis.pos) $ethis.mapType($id, $name, (null:$type));
	}

	public macro function mapTypeOf(ethis:Expr, value:Expr, ?name:Expr):Expr
	{
		var type = InjectorMacro.getValueId(value);
		return macro @:pos(ethis.pos) $ethis.mapType($type, $name);
	}

	public function mapRuntimeTypeOf(value:Dynamic, ?name:String):InjectorMapping<Dynamic>
	{
		return mapType(getValueType(value), name);
	}

	public macro function injectValue(ethis:Expr, value:Expr, ?name:Expr):Expr
	{
		var type = InjectorMacro.getValueId(value);
		return macro @:pos(ethis.pos) $ethis.mapType($type, $name).toValue($value);
	}

	/**
		Returns an `InjectorMapping` for the type identifier `type` with optional `name`

		This method is called by `map`, but can also be used to explicitly map a type identifier
		where it is not possible to provide it, such as for types with type parameters.

		```haxe
		var injector = new Injector();
		injector.mapType('Array<Int>', [0, 1, 2]);
		```

		@param type The type identifier to map
		@param name The optional name for the mapping
	**/
	public function mapType<T:Dynamic>(type:String, ?name:String, ?value:T):InjectorMapping<T>
	{
		var key = getMappingKey(type, name);
		if (mappings.exists(key))
			return cast mappings.get(key);
		var mapping = new InjectorMapping(type, name);
		mappings.set(key, mapping);
		return cast mapping;
	}

	/**
		Remove a mapping from the injector

		@param type The type to unmap
		@param name The optional name provided when the mapping was created
	**/
	public macro function unmap(ethis:Expr, type:Expr, ?name:Expr):Expr
	{
		var type = InjectorMacro.getExprType(type);
		return macro @:pos(ethis.pos) $ethis.unmapType($type, $name);
	}

	/**
		Remove a mapping from the injector

		@param type The type identifier to unmap
		@param name The optional name provided when the mapping was created
	**/
	public function unmapType(type:String, ?name:String):Void
	{
		#if debug
		if (!mappings.exists(getMappingKey(type, name)))
			throw 'Error while removing an mapping: No mapping defined for type "$type", name "$name"';
		#end
		mappings.remove(getMappingKey(type, name));
	}

	//-------------------------------------------------------------------------- mappings

	/**
		Does a mapping exist to satsify such a request?

		@param type The mapping type
		@param name The optional name provided when the mapping was created
		@returns Whether such a mapping exists
	**/
	public macro function hasMapping(ethis:Expr, type:Expr, ?name:Expr):Expr
	{
		var type = InjectorMacro.getExprType(type);
		return macro @:pos(ethis.pos) $ethis.hasMappingForType($type, $name);
	}

	/**
		Determines if this injector has a mapping for the provided `type` and `name`

		@param type The mapping type identifier
		@param name The optional name provided when the mapping was created
		@returns Whether such a mapping exists
	**/
	public function hasMappingForType(type:String, ?name:String):Bool
	{
		return findMappingForType(type, name) != null;
	}

	/**
		Determines if this injector or any of it's ancestors has a mapping with a provider for the
		provided `type` and `name`

		@param type The mapping type identifier
		@param name The optional name provided when the mapping was created
		@returns The mapping, if it exists, or `null`
	**/
	public function findMappingForType(type:String, name:String):InjectorMapping<Dynamic>
	{
		var mapping = mappings.get(getMappingKey(type, name));
		if (mapping != null && mapping.provider != null)
			return mapping;
		if (parent != null)
			return parent.findMappingForType(type, name);
		return null;
	}

	//-------------------------------------------------------------------------- response

	/**
		Returns the injectors response for the provided `type` and `name`

		If a matching mapping is not found then `null` is returned.

		@param type The mapping type
		@param name The optional name provided when the mapping was created
		@returns The injector response, if a mapping exists, or `null`
	**/
	public macro function getValue(ethis:Expr, type:Expr, ?name:Expr):Expr
	{
		var type = InjectorMacro.getExprType(type);
		return macro @:pos(ethis.pos) $ethis.getValueForType($type, $name);
	}

	/**
		Returns the injectors response for the provided `type` and `name`

		If a matching mapping is not found then `null` is returned.

		@param type The mapping type identifier
		@param name The optional name provided when the mapping was created
		@returns The injector response, if a mapping exists, or `null`
	**/
	public function getValueForType(type:String, ?name:String):Dynamic
	{
		var mapping = findMappingForType(type, name);
		if (mapping != null) return mapping.getValue(this);

		// if Array<Int> fails fall back to Array
		var index = type.indexOf('<');
		if (index > -1) mapping = findMappingForType(type.substr(0, index), name);
		if (mapping != null) return mapping.getValue(this);

		return null;
	}

	//-------------------------------------------------------------------------- injecting

	/**
		Perform an injection into `target`, satisfying all it's dependencies.

		@param target The object to inject into - the Injectee
	**/
	public function injectInto(target:Dynamic):Void
	{
		var info = getInfo(Type.getClass(target));

		// no injections for class
		if (info == null) return;

		for (field in info.fields)
			field.applyInjection(target, this);
	}

	/**
		Constructs an instance of `type` without satifying its dependencies.
	**/
	public macro function construct(ethis:Expr, type:Expr):Expr
	{
		InjectorMacro.keep(type);
		return macro @:pos(ethis.pos) ethis._construct(type);
	}

	@:dox(hide)
	@:noCompletion
	public function _construct<T>(type:Class<T>):T
	{
		var info = getInfo(type);
		return info.ctor.createInstance(type, this);
	}

	/**
		Create an object of the given class, supplying its dependencies as constructor parameters
		if the used DI solution has support for constructor injection

		Adapters for DI solutions that don't support constructor injection should just create a new
		instance and perform setter and/or method injection on that.

		NOTE: This method will always create a new instance. If you need to retrieve an instance
		consider using `getInstance`

		The `Injector` should throw an `Error` if it can't satisfy all dependencies of the injectee.

		@param type The class to instantiate
		@returns The created instance
	**/
	public macro function instantiate(ethis:Expr, type:Expr):Expr
	{
		InjectorMacro.keep(type);
		return macro @:pos(ethis.pos) $ethis._instantiate($type);
	}

	@:dox(hide)
	@:noCompletion
	public function _instantiate<T>(type:Class<T>):T
	{
		var instance = _construct(type);
		injectInto(instance);
		return instance;
	}

	/**
		Create or retrieve an instance of the given class

		@param type The class to retrieve.
		@param name An optional name
		@return An instance
	**/
	public function getInstance<T>(type:Class<T>, ?name:String):T
	{
		var type = Type.getClassName(type);
		var mapping = findMappingForType(type, name);

		if (mapping == null)
		{
			throw 'Error while getting mapping response: No mapping defined for class "$type" ' +
				'name "$name"';
		}

		return mapping.getValue(this);
	}

	/**
		Create an injector that inherits mappings from its parent

		@returns The injector
	**/
	public function createChildInjector():Injector
	{
		return new Injector(this);
	}

	//-------------------------------------------------------------------------- private

	function getInfo(forClass:Class<Dynamic>):InjectorInfo
	{
		var type = Type.getClassName(forClass);
		if (infos.exists(type))
			return infos.get(type);
		var info = createInfo(forClass);
		infos.set(type, info);
		return info;
	}

	function createInfo(forClass:Class<Dynamic>):InjectorInfo
	{
		var info = new InjectorInfo(null, []);
		addClassToInfo(forClass, info, []);
		// sort rtti to ensure post constructors are last and in order
		ArraySort.sort(info.fields, function(p1,p2) {
			var post1 = Std.instance(p1,PostInjectionPoint);
			var post2 = Std.instance(p2,PostInjectionPoint);
			return switch ([post1, post2])
			{
				case [null,null]: 0;
				case [null,_]: -1;
				case [_,null]: 1;
				default: post1.order - post2.order;
			}
		});
		if (info.ctor == null) info.ctor = new ConstructorInjectionPoint([]);
		return info;
	}

	function addClassToInfo(forClass:Class<Dynamic>, info:InjectorInfo, injected:Array<String>):Void
	{
		var meta = Meta.getType(forClass);

		#if debug
		if (meta != null && Reflect.hasField(meta, 'interface'))
			throw 'Interfaces can\'t be used as instantiatable classes.';
		#end

		var fields:Array<Array<String>> = cast meta.rtti;

		if (fields != null)
		{
			for (field in fields)
			{
				var name = field[0];

				if (injected.indexOf(name) > -1) continue;
				injected.push(name);

				if (field.length == 3)
				{
					info.fields.push(new PropertyInjectionPoint(name, field[1], field[2]));
				}
				else if (name == 'new')
				{
					info.ctor = new ConstructorInjectionPoint(field.slice(2));
				}
				else
				{
					var orderStr = field[1];
					if (orderStr == '')
					{
						info.fields.push(new MethodInjectionPoint(name, field.slice(2)));
					}
					else
					{
						var order = Std.parseInt(orderStr);
						info.fields.push(new PostInjectionPoint(name, field.slice(2), order));
					}
				}
			}
		}

		var superClass = Type.getSuperClass(forClass);
		if (superClass != null) addClassToInfo(superClass, info, injected);
	}

	function getMappingKey(type:String, name:String):String
	{
		if (name == null) name = '';
		return '$type#$name';
	}
}
