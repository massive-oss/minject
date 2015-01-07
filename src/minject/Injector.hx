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

import minject.point.*;
import minject.result.*;

/**
	The dependency injector
**/
#if !macro @:build(minject.Macro.addMetadata()) #end class Injector
{
	/**
		The parent of this injector
	**/
	public var parentInjector(default, null):Injector;

	// map of injector rules by className#name
	var rules = new Map<String, InjectorRule>();

	// map of injector descriptions by className
	var descriptions = new Map<String, InjectorDescription>();
	
	public function new() {}
	
	/**
		When asked for an instance of the class `whenAskedFor` inject the
		instance `useValue`.
		
		This is used to register an existing instance with the injector and
		treat it like a Singleton.
		
		@param whenAskedFor A class or interface
		@param useValue An instance
		@param named An optional name (id)
		
		@returns A reference to the rule for this injection. To be used
		with `mapRule`
	**/
	public function mapValue(whenAskedFor:Class<Dynamic>, useValue:Dynamic, ?named:String = ""):InjectorRule
	{
		var rule = getRule(whenAskedFor, named);
		rule.setResult(new InjectValueResult(useValue));
		return rule;
	}
	
	/**
		When asked for an instance of the class `whenAskedFor` inject a new
		instance of `instantiateClass`.
		
		This will create a new instance for each injection.
		
		@param whenAskedFor A class or interface
		@param instantiateClass A class to instantiate
		@param named An optional name (id)

		@returns A reference to the rule for this injection. To be used
		with `mapRule`
	**/
	public function mapClass(whenAskedFor:Class<Dynamic>, instantiateClass:Class<Dynamic>, ?named:String=""):InjectorRule
	{
		var rule = getRule(whenAskedFor, named);
		rule.setResult(new InjectClassResult(instantiateClass));
		return rule;
	}
	
	/**
		When asked for an instance of the class `whenAskedFor` inject an
		instance of `whenAskedFor`.
		
		This will create an instance on the first injection, but will re-use
		that instance for subsequent injections.
		
		@param whenAskedFor A class or interface
		@param named An optional name (id)
		
		@returns A reference to the rule for this injection. To be used
		with `mapRule`
	**/
	public function mapSingleton(whenAskedFor:Class<Dynamic>, ?named:String="") :InjectorRule
	{
		return mapSingletonOf(whenAskedFor, whenAskedFor, named);
	}
	
	/**
		When asked for an instance of the class `whenAskedFor`
		inject an instance of `useSingletonOf`.
		
		This will create an instance on the first injection, but will re-use
		that instance for subsequent injections.
		
		@param whenAskedFor A class or interface
		@param useSingletonOf A class to instantiate
		@param named An optional name (id)
		
		@returns A reference to the rule for this injection. To be used
		with `mapRule`
	**/
	public function mapSingletonOf(whenAskedFor:Class<Dynamic>, useSingletonOf:Class<Dynamic>, ?named:String=""):InjectorRule
	{
		var rule = getRule(whenAskedFor, named);
		rule.setResult(new InjectSingletonResult(useSingletonOf));
		return rule;
	}
	
	/**
		Perform an injection into an object, satisfying all it's dependencies
		
		The `Injector` should throw an `Error` if it can't satisfy all
		dependencies of the injectee.
		
		@param target The object to inject into - the Injectee
	**/
	public function injectInto(target:Dynamic):Void
	{
		var theClass = Type.getClass(target);
		var description = getDescription(theClass);

		// no injections for class
		if (description == null) return;

		for (injectionPoint in description.injectionPoints)
			injectionPoint.applyInjection(target, this);
	}
	
	/**
		Constructs an instance of theClass without satifying its dependencies.
	**/
	public function construct<T>(theClass:Class<T>):T
	{
		var description = getDescription(theClass);
		return description.ctor.applyInjection(theClass, this);
	}

	/**
		Create an object of the given class, supplying its dependencies as
		constructor parameters if the used DI solution has support for
		constructor injection
		
		Adapters for DI solutions that don't support constructor injection 
		should just create a new instance and perform setter and/or method
		injection on that.
		
		NOTE: This method will always create a new instance. If you need to
		retrieve an instance consider using `getInstance`
		
		The `Injector` should throw an `Error` if it can't satisfy all
		dependencies of the injectee.
		
		@param theClass The class to instantiate
		@returns The created instance
	**/
	public function instantiate<T>(theClass:Class<T>):T
	{
		var instance = construct(theClass);
		injectInto(instance);
		return instance;
	}
	
	/**
		Remove a rule from the injector

		@param theClass A class or interface
		@param named An optional name (id)
	**/
	public function unmap(theClass:Class<Dynamic>, ?named:String=""):Void
	{
		var rule = getRuleForRequest(theClass, named);
		
		if (rule == null)
		{
			throw 'Error while removing an injector rule: No rule defined for class ' +
				getClassName(theClass) + ', named "' + named + '"';
		}

		rule.setResult(null);
	}

	/**
		Does a rule exist to satsify such a request?

		@param forClass A class or interface
		@param named An optional name (id)
		@returns Whether such a rule exists
	**/
	public function hasRule(forClass:Class<Dynamic>, ?named:String = ''):Bool
	{
		var rule = getRuleForRequest(forClass, named);
		
		if (rule == null)
		{
			return false;
		}

		return rule.hasResponse(this);
	}

	/**
	**/
	public function getRule(forClass:Class<Dynamic>, ?named:String=""):InjectorRule
	{
		var requestName = getClassName(forClass) + "#" + named;
		
		if (rules.exists(requestName))
		{
			return rules.get(requestName);
		}
		
		var rule = new InjectorRule(forClass, named);
		rules.set(requestName, rule);
		return rule;
	}

	/**
		Searches for an injection rule in the ancestry of the injector. This
		method is called when a dependency cannot be satisfied by this injector.
	**/
	public function getAncestorRule(forClass:Class<Dynamic>, named:String=null):InjectorRule
	{
		var parent = parentInjector;

		while (parent != null)
		{
			var parentConfig = parent.getRuleForRequest(forClass, named, false);

			if (parentConfig != null && parentConfig.hasOwnResponse())
			{
				return parentConfig;
			}

			parent = parent.parentInjector;
		}
		
		return null;
	}

	/**
		When asked for an instance of the class `whenAskedFor`
		use rule `useRule` to determine the correct injection.
		
		This will use whatever injection is set by the given injection rule as
		created using one of the other rule methods.
		
		@param whenAskedFor A class or interface
		@param useRule The rule to use for the injection
		@param named An optional name (id)
		
		@returns A reference to the rule for this injection. To be used
		with `mapRule`
	**/
	public function mapRule(whenAskedFor:Class<Dynamic>, useRule:InjectorRule, ?named:String = ""):InjectorRule
	{
		var rule = getRule(whenAskedFor, named);
		rule.setResult(new InjectOtherRuleResult(useRule));
		return useRule;
	}

	/**
		Create or retrieve an instance of the given class
		
		@param ofClass The class to retrieve.
		@param named An optional name (id)
		@return An instance
	**/
	public function getInstance<T>(ofClass:Class<T>, ?named:String=""):T
	{
		var rule = getRuleForRequest(ofClass, named);
		
		if (rule == null || !rule.hasResponse(this))
		{
			throw 'Error while getting rule response: No rule defined for class ' +
				getClassName(ofClass) + ', named "' + named + '"';
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
		injector.parentInjector = this;
		return injector;
	}

	// private
	
	function getDescription(forClass:Class<Dynamic>):InjectorDescription
	{
		var name = Type.getClassName(forClass);
		if (descriptions.exists(name))
			return descriptions.get(name);
		var description = createDescription(forClass);
		descriptions.set(name, description);
		return description;
	}

	function createDescription(forClass:Class<Dynamic>):InjectorDescription
	{
		var typeMeta = Meta.getType(forClass);

		#if debug
		if (typeMeta != null && Reflect.hasField(typeMeta, "interface"))
			throw "Interfaces can't be used as instantiatable classes.";
		#end

		var fieldsMeta = getFields(forClass);
		var ctorInjectionPoint:InjectionPoint = null;
		var injectionPoints:Array<InjectionPoint> = [];
		var postConstructMethodPoints:Array<Dynamic> = [];
		
		for (field in Reflect.fields(fieldsMeta))
		{
			var fieldMeta:Dynamic = Reflect.field(fieldsMeta, field);
			// fieldMeta.name = field;

			var inject = Reflect.hasField(fieldMeta, "inject");
			var post = Reflect.hasField(fieldMeta, "post");
			var type = Reflect.field(fieldMeta, "type");
			var args = Reflect.field(fieldMeta, "args");
			
			if (field == "_") // constructor
			{
				if (args.length > 0)
				{
					ctorInjectionPoint = new ConstructorInjectionPoint(fieldMeta.args);
				}
			}
			else if (Reflect.hasField(fieldMeta, "args")) // method
			{
				if (inject) // injection
				{
					var point = new MethodInjectionPoint(field, fieldMeta.args);
					injectionPoints.push(point);
				}
				else if (post) // post construction
				{
					var order = fieldMeta.post == null ? 0 : fieldMeta.post[0];
					var point = new PostConstructInjectionPoint(field, order);
					postConstructMethodPoints.push(point);
				}
			}
			else if (type != null) // property
			{
				var name = fieldMeta.inject == null ? null : fieldMeta.inject[0];
				var point = new PropertyInjectionPoint(field, fieldMeta.type[0], name);
				injectionPoints.push(point);
			}
		}

		if (postConstructMethodPoints.length > 0)
		{
			postConstructMethodPoints.sort(function(a, b) { return a.order - b.order; });
			for (point in postConstructMethodPoints) injectionPoints.push(point);
		}

		if (ctorInjectionPoint == null)
			ctorInjectionPoint = new ConstructorInjectionPoint([]);

		return new InjectorDescription(ctorInjectionPoint, injectionPoints);
	}

	function getRuleForRequest(forClass:Class<Dynamic>, named:String, ?traverseAncestors:Bool=true):InjectorRule
	{
		var requestName = getClassName(forClass) + '#' + named;
		
		if (!rules.exists(requestName))
		{
			if (traverseAncestors && parentInjector != null 
				&& parentInjector.hasRule(forClass, named))
					return getAncestorRule(forClass, named);
			return null;
		}

		return rules.get(requestName);
	}

	function getClassName(forClass:Class<Dynamic>):String
	{
		if (forClass == null) return "Dynamic";
		else return Type.getClassName(forClass);
	}

	function getFields(type:Class<Dynamic>)
	{
		var meta = {};
		while (type != null)
		{
			var typeMeta = haxe.rtti.Meta.getFields(type);
			for (field in Reflect.fields(typeMeta))
				Reflect.setField(meta, field, Reflect.field(typeMeta, field));
			type = Type.getSuperClass(type);
		}
		return meta;
	}
}
