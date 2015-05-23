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
	public static function getTypeName(value:Dynamic)
	{
		if (Std.is(value, String)) return value;

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

	public function new() {}

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
		var type = InjectorMacro.getTypeName(forType);
		return macro $ethis.mapTypeValue($type, $useValue, $named);
	}

	public function mapTypeValue(forType:String, useValue:Dynamic, ?named:String):InjectorRule
	{
		var rule = getTypeRule(forType, named);
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
		return macro $ethis._mapClass($forType, $instantiateClass, $named);
	}

	public function _mapClass(forType:Class<Dynamic>, instantiateClass:Class<Dynamic>,
		?named:String):InjectorRule
	{
		var rule = getTypeRule(Type.getClassName(forType), named);
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
		return macro $ethis._mapSingletonOf($forType, $forType, $named);
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
		return macro $ethis._mapSingletonOf($forType, $useSingletonOf, $named);
	}

	public function _mapSingletonOf(forType:Class<Dynamic>, useSingletonOf:Class<Dynamic>,
		?named:String):InjectorRule
	{
		var rule = getTypeRule(Type.getClassName(forType), named);
		rule.setResult(new InjectSingletonResult(useSingletonOf));
		return rule;
	}

	/**
		Remove a rule from the injector

		@param theClass A class or interface
		@param named An optional name (id)
	**/
	public macro function unmap(ethis:Expr, forType:Expr, ?named:Expr):Expr
	{
		var type = InjectorMacro.getTypeName(forType);
		return macro $ethis.unmapType($type, $named);
	}

	public function unmapType(type:String, ?named:String):Void
	{
		var rule = getRuleForRequest(type, named);
		#if debug
		if (rule == null)
			throw 'Error while removing an rule: No rule defined for class "$type", named "$named"';
		#end
		rule.setResult(null);
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
		var type = InjectorMacro.getTypeName(forType);
		return macro $ethis.hasTypeRule($type, $named);
	}

	public function hasTypeRule(forType:String, ?named:String):Bool
	{
		var rule = getRuleForRequest(forType, named);
		if (rule == null) return false;
		return rule.hasResponse(this);
	}

	/**
		Returns the mapped `InjectorRule` for the class and name provided.
	**/
	public macro function getRule(ethis:Expr, forType:Expr, ?named:Expr):Expr
	{
		var type = InjectorMacro.getTypeName(forType);
		return macro $ethis.getTypeRule($type, $named);
	}

	public function getTypeRule(forType:String, ?named:String):InjectorRule
	{
		var requestName = getRequestName(forType, named);
		if (rules.exists(requestName))
			return rules.get(requestName);

		var rule = new InjectorRule(forType, named);
		rules.set(requestName, rule);
		return rule;
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
		var type = InjectorMacro.getTypeName(forType);
		return macro $ethis.mapTypeRule($type, $useRule, $named);
	}

	public function mapTypeRule(forType:String, useRule:InjectorRule, ?named:String):InjectorRule
	{
		var rule = getTypeRule(forType, named);
		rule.setResult(new InjectOtherRuleResult(useRule));
		return useRule;
	}

	/**
		Searches for an injection rule in the ancestry of the injector. This method is called when
		a dependency cannot be satisfied by this injector.
	**/
	public function getAncestorRule(forType:String, ?named:String):InjectorRule
	{
		var parent = parent;

		while (parent != null)
		{
			var parentConfig = parent.getRuleForRequest(forType, named, false);

			if (parentConfig != null && parentConfig.hasOwnResponse())
			{
				return parentConfig;
			}

			parent = parent.parent;
		}

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

		for (injectionPoint in info.injectionPoints)
			injectionPoint.applyInjection(target, this);
	}

	/**
		Constructs an instance of theClass without satifying its dependencies.
	**/
	public macro function construct(ethis:Expr, theClass:Expr):Expr
	{
		InjectorMacro.keep(theClass);
		return macro ethis._construct(theClass);
	}

	public function _construct<T>(theClass:Class<T>):T
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
		return macro $ethis._instantiate($theClass);
	}

	public function _instantiate<T>(theClass:Class<T>):T
	{
		var instance = _construct(theClass);
		injectInto(instance);
		return instance;
	}

	/**
		Returns the injectors response for the provided type and name.

		This method will return responses mapped through any method: mapValue, mapClass
		or mapSingleton.

		If a matching rule is not found then null is returned.
	**/
	public macro function getResponse(ethis:Expr, forType:Expr, ?named:Expr):Expr
	{
		var type = InjectorMacro.getTypeName(forType);
		return macro $ethis.getTypeResponse($type, $named);
	}

	public function getTypeResponse(forType:String, ?named:String):Dynamic
	{
		var rule = getRuleForRequest(forType, named, true);
		var response = (rule!=null) ? rule.getResponse(this) : null;

		if (response == null)
		{
			// if Array<Int> fails fall back to Array
			var index = forType.indexOf("<");
			if (index > -1) {
				rule = getRuleForRequest(forType.substr(0, index), named);
				response = (rule!=null) ? rule.getResponse(this) : null;
			}
		}
		return response;
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
		var rule = getRuleForRequest(type, named);

		if (rule == null || !rule.hasResponse(this))
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
		var injector = new Injector();
		injector.parent = this;
		return injector;
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
					info.injectionPoints.push(new PropertyInjectionPoint(name, field[1], field[2]));
				}
				else
				{
					info.injectionPoints.push(new MethodInjectionPoint(name, field.slice(1)));
				}
			}
		}

		var superClass = Type.getSuperClass(forClass);
		if (superClass != null) addClassToInfo(superClass, info, injected);
	}

	function getRuleForRequest(type:String, named:String, ?traverseAncestors:Bool=true):InjectorRule
	{
		var requestName = getRequestName(type, named);

		if (!rules.exists(requestName))
		{
			if (traverseAncestors && parent != null
				&& parent.hasTypeRule(type, named))
					return getAncestorRule(type, named);
			return null;
		}

		return rules.get(requestName);
	}

	function getRequestName(forType:String, named:String):String
	{
		if (named == null) named = '';
		return '$forType#$named';
	}
}
