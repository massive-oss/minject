/*
Copyright (c) 2012-2014 Massive Interactive

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
import haxe.ds.WeakMap;
import minject.point.ConstructorInjectionPoint;
import minject.point.InjectionPoint;
import minject.point.MethodInjectionPoint;
import minject.point.NoParamsConstructorInjectionPoint;
import minject.point.PostConstructInjectionPoint;
import minject.point.PropertyInjectionPoint;
import minject.result.InjectClassResult;
import minject.result.InjectOtherRuleResult;
import minject.result.InjectSingletonResult;
import minject.result.InjectValueResult;

/**
	The dependency injector.
**/
#if !macro @:build(minject.Macro.addMetadata()) #end class Injector
{
	/**
		A set of instances that have already had their dependencies satisfied by the injector.
	**/
	public var attendedToInjectees(default, null):InjecteeSet;

	/**
		The parent of this injector.
	**/
	public var parentInjector(default, set):Injector;

	var injectionConfigs:Map<String, InjectionConfig>;
	var injecteeDescriptions:ClassMap<InjecteeDescription>;
	
	public function new()
	{
		injectionConfigs = new Map();
		injecteeDescriptions = new ClassMap();
		attendedToInjectees = new InjecteeSet();
	}
	
	/**
		When asked for an instance of the class `whenAskedFor` inject the instance `useValue`.
		
		This is used to register an existing instance with the injector and treat it like a 
		Singleton.
		
		@param whenAskedFor A class or interface
		@param useValue An instance
		@param named An optional name (id)
		
		@returns A reference to the rule for this injection. To be used with `mapRule`
	**/
	public function mapValue(whenAskedFor:Class<Dynamic>, useValue:Dynamic, ?named:String = ""):Dynamic
	{
		var config = getMapping(whenAskedFor, named);
		config.setResult(new InjectValueResult(useValue));
		return config;
	}
	
	/**
		When asked for an instance of the class `whenAskedFor` inject a new instance of 
		`instantiateClass`.
		
		This will create a new instance for each injection.
		
		@param whenAskedFor A class or interface
		@param instantiateClass A class to instantiate
		@param named An optional name (id)

		@returns A reference to the rule for this injection. To be used with `mapRule`
	**/
	public function mapClass(whenAskedFor:Class<Dynamic>, instantiateClass:Class<Dynamic>, ?named:String=""):Dynamic
	{
		var config = getMapping(whenAskedFor, named);
		config.setResult(new InjectClassResult(instantiateClass));
		return config;
	}
	
	/**
		When asked for an instance of the class `whenAskedFor` inject an instance of `whenAskedFor`.
		
		This will create an instance on the first injection, but will re-use that instance for 
		subsequent injections.
		
		@param whenAskedFor A class or interface
		@param named An optional name (id)
		
		@returns A reference to the rule for this injection. To be used with `mapRule`
	**/
	public function mapSingleton(whenAskedFor:Class<Dynamic>, ?named:String="") :Dynamic
	{
		return mapSingletonOf(whenAskedFor, whenAskedFor, named);
	}
	
	/**
		When asked for an instance of the class `whenAskedFor`
		inject an instance of `useSingletonOf`.
		
		This will create an instance on the first injection, but will re-use that instance for 
		subsequent injections.
		
		@param whenAskedFor A class or interface
		@param useSingletonOf A class to instantiate
		@param named An optional name (id)
		
		@returns A reference to the rule for this injection. To be used with `mapRule`
	**/
	public function mapSingletonOf(whenAskedFor:Class<Dynamic>, useSingletonOf:Class<Dynamic>, ?named:String=""):Dynamic
	{
		var config = getMapping(whenAskedFor, named);
		config.setResult(new InjectSingletonResult(useSingletonOf));
		return config;
	}
	
	/**
		When asked for an instance of the class `whenAskedFor`
		use rule `useRule` to determine the correct injection.
		
		This will use whatever injection is set by the given injection rule as created using one 
		of the other mapping methods.
		
		@param whenAskedFor A class or interface
		@param useRule The rule to use for the injection
		@param named An optional name (id)
		
		@returns A reference to the rule for this injection. To be used with `mapRule`
	**/
	public function mapRule(whenAskedFor:Class<Dynamic>, useRule:Dynamic, ?named:String = ""):Dynamic
	{
		var config = getMapping(whenAskedFor, named);
		config.setResult(new InjectOtherRuleResult(useRule));
		return useRule;
	}
	
	public function getMapping(forClass:Class<Dynamic>, ?named:String=""):InjectionConfig
	{
		var requestName = getClassName(forClass) + "#" + named;
		
		if (injectionConfigs.exists(requestName))
		{
			return injectionConfigs.get(requestName);
		}
		
		var config = new InjectionConfig(forClass, named);
		injectionConfigs.set(requestName, config);
		return config;
	}
	
	/**
		Perform an injection into an object, satisfying all it's dependencies
		
		The `Injector` should throw an `Error` if it can't satisfy all dependencies of the injectee.
		
		@param target The object to inject into - the Injectee
	**/
	public function injectInto(target:Dynamic):Void
	{
		if (attendedToInjectees.contains(target))
		{
			return;
		}

		attendedToInjectees.add(target);

		// get injection points or cache them if this target's class wasn't encountered before
		var targetClass = Type.getClass(target);

		var injecteeDescription:InjecteeDescription = null;

		if (injecteeDescriptions.exists(targetClass))
		{
			injecteeDescription = injecteeDescriptions.get(targetClass);
		}
		else
		{
			injecteeDescription = getInjectionPoints(targetClass);
		}

		if (injecteeDescription == null) return;

		var injectionPoints:Array<Dynamic> = injecteeDescription.injectionPoints;
		var length:Int = injectionPoints.length;

		for (i in 0...length)
		{
			var injectionPoint:InjectionPoint = injectionPoints[i];
			injectionPoint.applyInjection(target, this);
		}
	}
	
	/**
		Constructs an instance of theClass without satifying its dependencies.
	**/
	public function construct<T>(theClass:Class<T>):T
	{
		var injecteeDescription:InjecteeDescription;

		if (injecteeDescriptions.exists(theClass))
		{
			injecteeDescription = injecteeDescriptions.get(theClass);
		}
		else
		{
			injecteeDescription = getInjectionPoints(theClass);
		}

		var injectionPoint:InjectionPoint = injecteeDescription.ctor;
		return injectionPoint.applyInjection(theClass, this);
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
		var mapping = getConfigurationForRequest(theClass, named);
		
		if (mapping == null)
		{
			throw 'Error while removing an injector mapping: No mapping defined for class ' + getClassName(theClass) + ', named "' + named + '"';
		}

		mapping.setResult(null);
	}

	/**
		Does a rule exist to satsify such a request?

		@param forClass A class or interface
		@param named An optional name (id)
		@returns Whether such a mapping exists
	**/
	public function hasMapping(forClass:Class<Dynamic>, ?named:String = ''):Bool
	{
		var mapping = getConfigurationForRequest(forClass, named);
		
		if (mapping == null)
		{
			return false;
		}

		return mapping.hasResponse(this);
	}

	/**
		Create or retrieve an instance of the given class
		
		@param ofClass The class to retrieve.
		@param named An optional name (id)
		@return An instance
	**/
	public function getInstance<T>(ofClass:Class<T>, ?named:String=""):T
	{
		var mapping = getConfigurationForRequest(ofClass, named);
		
		if (mapping == null || !mapping.hasResponse(this))
		{
			throw 'Error while getting mapping response: No mapping defined for class ' + getClassName(ofClass) + ', named "' + named + '"';
		}

		return mapping.getResponse(this);
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

	/**
		Searches for an injection mapping in the ancestry of the injector. This method is called 
		when a dependency cannot be satisfied by this injector.
	**/
	public function getAncestorMapping(forClass:Class<Dynamic>, named:String=null):InjectionConfig
	{
		var parent = parentInjector;

		while (parent != null)
		{
			var parentConfig = parent.getConfigurationForRequest(forClass, named, false);

			if (parentConfig != null && parentConfig.hasOwnResponse())
			{
				return parentConfig;
			}

			parent = parent.parentInjector;
		}
		
		return null;
	}

	function getInjectionPoints(forClass:Class<Dynamic>):InjecteeDescription
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

			if(!post && !inject) processCustomInjectionPoints(forClass, field, fieldMeta, injectionPoints);
		}

		if (postConstructMethodPoints.length > 0)
		{
			postConstructMethodPoints.sort(function(a, b) { return a.order - b.order; });
			for (point in postConstructMethodPoints) injectionPoints.push(point);
		}

		if (ctorInjectionPoint == null)
			ctorInjectionPoint = new NoParamsConstructorInjectionPoint();

		var injecteeDescription = new InjecteeDescription(ctorInjectionPoint, injectionPoints);
		injecteeDescriptions.set(forClass, injecteeDescription);
		return injecteeDescription;
	}

	/**
	Provides a hook for framework extensions to add InjectionPoints for custom metadata.
	*/
	function processCustomInjectionPoints(clazz:Class<Dynamic>, field:String, fieldMeta:Dynamic, injectionPoints:Array<InjectionPoint>)
	{
		// override in subclass to handle custom metadata and insert InjectionPoints into the injectionPoints array;
	}

	function getConfigurationForRequest(forClass:Class<Dynamic>, named:String, ?traverseAncestors:Bool=true):InjectionConfig
	{
		var requestName = getClassName(forClass) + '#' + named;
		
		if (!injectionConfigs.exists(requestName))
		{
			if (traverseAncestors && parentInjector != null 
				&& parentInjector.hasMapping(forClass, named))
					return getAncestorMapping(forClass, named);
			return null;
		}

		return injectionConfigs.get(requestName);
	}

	function set_parentInjector(value:Injector):Injector
	{
		// restore own map of worked injectees if parent injector is removed
		if (parentInjector != null && value == null) attendedToInjectees = new InjecteeSet();

		parentInjector = value;

		// use parent's map of worked injectees
		if (parentInjector != null) attendedToInjectees = parentInjector.attendedToInjectees;

		return parentInjector;
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

/**
	Contains the set of objects which have been injected into.
	 
	Under dynamic languages that don't support weak references this set a 
	hidden property on an injectee when added, to mark it as injected. This is 
	to avoid storing a direct reference of it here, causing it never to be 
	available for GC.
**/
class InjecteeSet
{
	#if (flash9 || cpp || java || php)
	var map:WeakMap<Dynamic, Bool>;
	#end
	
	public function new()
	{
		#if (flash9 || cpp || java || php)
		map = new WeakMap();
		#end
	}

	public function add(value:Dynamic)
	{
		#if (flash9 || cpp || java || php)
		map.set(value, true);
		#else
		value.__injected__ = true;
		#end
	}

	public function contains(value:Dynamic)
	{
		#if (flash9 || cpp || java || php)
		return map.exists(value);
		#else
		return value.__injected__ == true;
		#end
	}

	public function remove(value:Dynamic)
	{
		#if (flash9 || cpp || java || php)
		map.remove(value);
		#else
		Reflect.deleteField(value, "__injected__");
		#end
	}

	// deprecated
	inline public function delete(value:Dynamic) remove(value);

	/**
		Under dynamic targets that don't support weak refs (js, avm1, neko) this will always 
		return an empty iterator due to values not being stored in this set. This is to avoid 
		memory leaks.
	**/
	public function iterator()
	{
		#if (flash9 || cpp || java || php)
		return map.iterator();
		#else
		return [].iterator();
		#end
	}
}

class InjecteeDescription
{
	public var ctor:InjectionPoint;
	public var injectionPoints:Array<InjectionPoint>;
 
	public function new(ctor:InjectionPoint, injectionPoints:Array<InjectionPoint>)
	{
		this.ctor = ctor;
		this.injectionPoints = injectionPoints;
	}
}
