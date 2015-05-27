/*
Copyright (c) 2012-2015 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package minject;

import haxe.rtti.Meta;
import haxe.macro.Expr;

import minject.point.*;
import minject.result.*;

/**
	The dependency injector
**/
#if !macro @:build(minject.InjectorMacro.addMetadata()) #end
class Injector
{
	public static macro function getExprTypeId(expr:Expr):Expr
	{
		return InjectorMacro.getExprTypeId(expr);
	}

	public static function getValueTypeId(value:Dynamic)
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

	// map of injector rules by className#name
	var rules = new Map<String, InjectorRule>();

	// map of injector infos by className
	var infos = new Map<String, InjectorInfo>();

	public function new(?parent:Injector)
	{
		this.parent = parent;
	}

	//-------------------------------------------------------------------------- mapping

	/**
		When asked for an instance of the type `forType` inject the instance `useValue`.

		This is used to register an existing value with the injector and treat it like a singleton.

		@param forType A class or interface
		@param useValue An instance
		@param named An optional name (id)

		@returns A reference to the rule for this injection which can be used with `mapRule`
	**/
	public macro function mapValue(ethis:Expr, forType:Expr, useValue:Expr, ?named:Expr):Expr
	{
		InjectorMacro.keep(forType);
		var forTypeId = InjectorMacro.getExprTypeId(forType);
		return macro $ethis.mapValueToTypeId($forTypeId, $useValue, $named);
	}

	public function mapValueToTypeId(forTypeId:String, useValue:Dynamic, ?named:String):InjectorRule
	{
		var rule = getRuleForTypeId(forTypeId, named);
		rule.setResult(new InjectValueResult(useValue));
		return rule;
	}

	/**
		When asked for an instance of the class `forType` inject a new instance of
		`instantiateClass`.

		This will create a new instance for each injection.

		@param forType A class or interface
		@param instantiateClass A class to instantiate
		@param named An optional name (id)

		@returns A reference to the rule for this injection which can be used with `mapRule`
	**/
	public macro function mapClass(ethis:Expr, forType:Expr, instantiateClass:Expr,
		?named:Expr):Expr
	{
		InjectorMacro.keep(instantiateClass);
		var forTypeId = InjectorMacro.getExprTypeId(forType);
		return macro $ethis.mapClassToTypeId($forTypeId, $instantiateClass, $named);
	}

	public function mapClassToTypeId(forTypeId:String, instantiateClass:Class<Dynamic>,
		?named:String):InjectorRule
	{
		var rule = getRuleForTypeId(forTypeId, named);
		rule.setResult(new InjectClassResult(instantiateClass));
		return rule;
	}

	/**
		When asked for an instance of the class `forType` inject an instance of `forType`.

		This will create an instance on the first injection, but will re-use that instance for
		subsequent injections.

		@param forType A class or interface
		@param named An optional name (id)

		@returns A reference to the rule for this injection which can be used with `mapRule`
	**/
	public macro function mapSingleton(ethis:Expr, forType:Expr, ?named:Expr):Expr
	{
		InjectorMacro.keep(forType);
		var forTypeId = InjectorMacro.getExprTypeId(forType);
		return macro $ethis.mapSingletonOfToTypeId($forTypeId, $forType, $named);
	}

	/**
		When asked for an instance of the class `forType` inject an instance of `useSingletonOf`.

		This will create an instance on the first injection, but will re-use that instance for
		subsequent injections.

		@param forType A class or interface
		@param useSingletonOf A class to instantiate
		@param named An optional name

		@returns A reference to the rule for this injection which can be used with `mapRule`
	**/
	public macro function mapSingletonOf(ethis:Expr, forType:Expr, useSingletonOf:Expr,
		?named:Expr):Expr
	{
		InjectorMacro.keep(useSingletonOf);
		var forTypeId = InjectorMacro.getExprTypeId(forType);
		return macro $ethis.mapSingletonOfToTypeId($forTypeId, $useSingletonOf, $named);
	}

	public function mapSingletonOfToTypeId(forTypeId:String, useSingletonOf:Class<Dynamic>,
		?named:String):InjectorRule
	{
		var rule = getRuleForTypeId(forTypeId, named);
		rule.setResult(new InjectSingletonResult(useSingletonOf));
		return rule;
	}

	//-------------------------------------------------------------------------- rules

	/**
		Does a rule exist to satsify such a request?

		@param forType A class or interface
		@param named An optional name (id)
		@returns Whether such a rule exists
	**/
	public macro function hasRule(ethis:Expr, forType:Expr, ?named:Expr):Expr
	{
		var type = InjectorMacro.getExprTypeId(forType);
		return macro $ethis.hasRuleForTypeId($type, $named);
	}

	public function hasRuleForTypeId(forTypeId:String, ?named:String):Bool
	{
		return findRuleForTypeId(forTypeId, named) != null;
	}

	/**
		Returns the mapped `InjectorRule` for the type and name provided.
	**/
	public macro function getRule(ethis:Expr, forType:Expr, ?named:Expr):Expr
	{
		var forTypeId = InjectorMacro.getExprTypeId(forType);
		return macro $ethis.getRuleForTypeId($forTypeId, $named);
	}

	public function getRuleForTypeId(forTypeId:String, ?named:String):InjectorRule
	{
		var key = getRuleKey(forTypeId, named);
		if (rules.exists(key))
			return rules.get(key);
		var rule = new InjectorRule(forTypeId, named);
		rules.set(key, rule);
		return rule;
	}

	public function findRuleForTypeId(type:String, named:String):InjectorRule
	{
		var rule = rules.get(getRuleKey(type, named));
		if (rule != null && rule.result != null)
			return rule;

		if (parent != null)
			return parent.findRuleForTypeId(type, named);

		return null;
	}

	/**
		When asked for an instance of the class `forType` use rule `useRule` to determine the
		correct injection.

		This will use whatever injection is set by the given injection rule as created using one of
		the other rule methods.

		@param forType A class or interface
		@param useRule The rule to use for the injection
		@param named An optional name (id)

		@returns A reference to the rule for this injection which can be used with `mapRule`
	**/
	public macro function mapRule(ethis:Expr, forType:Expr, useRule:Expr, ?named:Expr):Expr
	{
		var forTypeId = InjectorMacro.getExprTypeId(forType);
		return macro $ethis.mapRuleForTypeId($forTypeId, $useRule, $named);
	}

	public function mapRuleForTypeId(forTypeId:String, useRule:InjectorRule, ?named:String):InjectorRule
	{
		var rule = getRuleForTypeId(forTypeId, named);
		rule.setResult(new InjectOtherRuleResult(useRule));
		return useRule;
	}

	/**
		Remove a rule from the injector

		@param theClass A class or interface
		@param named An optional name (id)
	**/
	public macro function unmap(ethis:Expr, forType:Expr, ?named:Expr):Expr
	{
		var type = InjectorMacro.getExprTypeId(forType);
		return macro $ethis.unmapTypeId($type, $named);
	}

	public function unmapTypeId(path:String, ?named:String):Void
	{
		#if debug
		if (!rules.exists(getRuleKey(path, named)))
			throw 'Error while removing an rule: No rule defined for type "$path", named "$named"';
		#end
		rules.remove(getRuleKey(path, named));
	}

	//-------------------------------------------------------------------------- response

	/**
		Returns the injectors response for the provided type and name.

		This method will return responses mapped through any method: mapValue, mapClass
		or mapSingleton.

		If a matching rule is not found then null is returned.
	**/
	public macro function getResponse(ethis:Expr, forType:Expr, ?named:Expr):Expr
	{
		var forTypeId = InjectorMacro.getExprTypeId(forType);
		return macro $ethis.getResponseForTypeId($forTypeId, $named);
	}

	public function getResponseForTypeId(forTypeId:String, ?named:String):Dynamic
	{
		var rule = findRuleForTypeId(forTypeId, named);
		if (rule != null) return rule.getResponse(this);

		// if Array<Int> fails fall back to Array
		var index = forTypeId.indexOf("<");
		if (index > -1) rule = findRuleForTypeId(forTypeId.substr(0, index), named);
		if (rule != null) return rule.getResponse(this);

		return null;
	}

	//-------------------------------------------------------------------------- injecting

	/**
		Perform an injection into an object, satisfying all it's dependencies.

		The `Injector` should throw an `Error` if it can't satisfy all dependencies of the injectee.

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
		Constructs an instance of theClass without satifying its dependencies.
	**/
	public macro function construct(ethis:Expr, theClass:Expr):Expr
	{
		InjectorMacro.keep(theClass);
		return macro ethis.constructClass(theClass);
	}

	public function constructClass<T>(theClass:Class<T>):T
	{
		var info = getInfo(theClass);
		return info.ctor.applyInjection(theClass, this);
	}

	/**
		Create an object of the given class, supplying its dependencies as constructor parameters
		if the used DI solution has support for constructor injection

		Adapters for DI solutions that don't support constructor injection should just create a new
		instance and perform setter and/or method injection on that.

		NOTE: This method will always create a new instance. If you need to retrieve an instance
		consider using `getInstance`

		The `Injector` should throw an `Error` if it can't satisfy all dependencies of the injectee.

		@param theClass The class to instantiate
		@returns The created instance
	**/
	public macro function instantiate(ethis:Expr, theClass:Expr):Expr
	{
		InjectorMacro.keep(theClass);
		return macro $ethis.instantiateClass($theClass);
	}

	public function instantiateClass<T>(theClass:Class<T>):T
	{
		var instance = constructClass(theClass);
		injectInto(instance);
		return instance;
	}

	/**
		Create or retrieve an instance of the given class

		@param ofClass The class to retrieve.
		@param named An optional name (id)
		@return An instance
	**/
	public function getInstance<T>(ofClass:Class<T>, ?named:String):T
	{
		var type = Type.getClassName(ofClass);
		var rule = findRuleForTypeId(type, named);

		if (rule == null)
		{
			throw 'Error while getting rule response: No rule defined for class "$type" ' +
				'named "$named"';
		}

		return rule.getResponse(this);
	}

	/**
		Create an injector that inherits rules from its parent

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
		if (info.ctor == null) info.ctor = new ConstructorInjectionPoint([]);
		return info;
	}

	function addClassToInfo(forClass:Class<Dynamic>, info:InjectorInfo, injected:Array<String>):Void
	{
		var typeMeta = Meta.getType(forClass);

		#if debug
		if (typeMeta != null && Reflect.hasField(typeMeta, 'interface'))
			throw 'Interfaces can\'t be used as instantiatable classes.';
		#end

		var fields:Array<Array<String>> = cast typeMeta.rtti;

		if (fields != null)
		{
			for (field in fields)
			{
				var name = field[0];

				if (injected.indexOf(name) > -1) continue;
				injected.push(name);

				if (name == 'new')
				{
					info.ctor = new ConstructorInjectionPoint(field.slice(1));
				}
				else if (field.length == 3)
				{
					info.fields.push(new PropertyInjectionPoint(name, field[1], field[2]));
				}
				else
				{
					info.fields.push(new MethodInjectionPoint(name, field.slice(1)));
				}
			}
		}

		var superClass = Type.getSuperClass(forClass);
		if (superClass != null) addClassToInfo(superClass, info, injected);
	}

	function getRuleKey(type:String, name:String):String
	{
		if (name == null) name = '';
		return '$type#$name';
	}
}
