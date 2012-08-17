package mcore.util;

import Type;
import haxe.PosInfos;
using Lambda;
using Type;
using Reflect;
/**
Utility methods for working with reflection.
*/
class Reflection
{
	/**
	Sets the value of a property, calling it's setter if present and of 
	the format set_property.
	
	@param object		the object to set the property on
	@param property 	the property to set
	@param value 		the new value of the property
	@return the new value of the property
	*/
	public static function setProperty(object:Dynamic, property:String, value:Dynamic):Dynamic
	{
		#if js
		var hasSetter:Bool = untyped (object["set_" + property] != null);
		#elseif neko
		var hasSetter:Bool = Reflect.isFunction(Reflect.field(object, "set_" + property));
		#else
		var hasSetter:Bool = Reflect.hasField(object, "set_" + property);
		#end
		
		if (hasSetter)
		{
			Reflect.callMethod(object, Reflect.field(object, "set_" + property), [value]);
		}
		else
		{
			Reflect.setField(object, property, value);
		}
		
		return value;
	}
	
	/**
	A convenience method for checking if a class instance has a property.
	@param object 		the class instance to check
	@param property 	the property to check for
	@return true if the instance implements the property, false if not.
	*/
	public static function hasProperty(object:Dynamic, property:String):Bool
	{
		var properties = Type.getInstanceFields(Type.getClass(object));
		return properties.has(property);
	}
	
	/**
	Returns the instance fields of an object if it is a class instance, 
	or else it's reflected fields.
	
	@param object 		the object to reflect
	@return instance or reflected fields
	*/
	public static function getFields(object:Dynamic):Array<String>
	{
		return switch(object.typeof())
		{
			case TClass(c): c.getInstanceFields();
			default: object.fields();
		}
	}
	/**
	Returns information about the location this method is called.
	 */
	public static function here(?info:PosInfos):PosInfos
	{
		return info;
	}


	/**
	Wraps Reflect.callMethod to support optional arguments in neko
	
	@param o 	the given object to reflect on
	@param func reference to the function to call on (i.e. Reflect.field(o, "func");)
	@param args 	optional array of arguments
	*/
	public static function callMethod(o:Dynamic, func:Dynamic, ?args:Array<Dynamic>=null)
	{
		if (args == null) args = [];
		#if !neko
			try
			{
				return Reflect.callMethod(o, func, args);
			}
			catch(e:Dynamic)
			{
				throw "Error calling method " + Type.getClassName(Type.getClass(o)) + "." + func + "(" + args.toString() + ")";
			}
			
		#else
			var attempts = 0;
			do
			{
				try
				{
					return Reflect.callMethod(o, func, args);
				}
				catch (e:Dynamic)
				{
					if(e != "Invalid call")
					{
						throw "Error calling method " + Type.getClassName(Type.getClass(o)) + "." + func + "(" + args.toString() + ")";
					}
				}
				attempts ++;
				args.push(null);
			}
			while (attempts < 10);

			throw "Unable to call " + Type.getClassName(Type.getClass(o)) + "." + func + "(" + args.toString() + ")";
					
			
			return null;
		#end
	}

}
