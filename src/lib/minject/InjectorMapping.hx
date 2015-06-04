// See the file "LICENSE" for the full license governing this code

package minject;

import haxe.macro.Expr;

import minject.provider.*;

class InjectorMapping<T>
{
	public var type:String;
	public var name:String;

	public var injector:Injector;
	public var provider:DependencyProvider<T>;

	public function new(type:String, name:String)
	{
		this.type = type;
		this.name = name;
	}

	public function getValue(injector:Injector):T
	{
		if (this.injector != null)
			injector = this.injector;

		if (provider != null)
			return provider.getValue(injector);

		var parent = injector.findMappingForType(type, name);
		if (parent != null)
			return parent.getValue(injector);

		return null;
	}

	public function toValue(value:T):InjectorMapping<T>
	{
		return toProvider(new ValueProvider(value));
	}

	public macro function toClass(ethis:Expr, type:Expr):Expr
	{
		InjectorMacro.keep(type);
		return macro $ethis._toClass($type);
	}

	@:dox(hide)
	@:noCompletion
	public function _toClass(type:Class<T>):InjectorMapping<T>
	{
		return toProvider(new ClassProvider<T>(type));
	}

	public macro function toSingleton(ethis:Expr, type:Expr):Expr
	{
		InjectorMacro.keep(type);
		return macro $ethis._toSingleton($type);
	}

	@:dox(hide)
	@:noCompletion
	public function _toSingleton(type:Class<T>):InjectorMapping<T>
	{
		return toProvider(new SingletonProvider<T>(type));
	}

	public function asSingleton():InjectorMapping<T>
	{
		return _toSingleton(cast Type.resolveClass(type));
	}

	public function toMapping(mapping:InjectorMapping<Dynamic>):InjectorMapping<T>
	{
		return toProvider(new OtherMappingProvider(mapping));
	}

	public function toProvider(provider:DependencyProvider<T>):InjectorMapping<T>
	{
		#if debug
		if (this.provider != null && provider != null)
		{
			trace('Warning: Injector contains ${this.toString()}.\nAttempting to overwrite this ' +
				'with mapping for ${provider.toString()}.\nIf you have overwritten this mapping ' +
				'intentionally you can use `injector.unmap()` prior to your replacement mapping ' +
				'in order to avoid seeing this message.');
		}
		#end
		this.provider = provider;
		return this;
	}

	#if debug
	public function toString():String
	{
		var named = name != null && name != '' ? ' named "$name" and' : '';
		return 'mapping: [$type]$named mapped to [$provider]';
	}
	#end
}
