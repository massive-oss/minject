/*
Copyright (c) 2012 Massive Interactive

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

package mcore.util;

import Type;
using Lambda;
using Type;
using Reflect;
import haxe.PosInfos;

import mcore.exception.ArgumentException;
import mcore.exception.Exception;

/**
Utility methods for working with reflection.
*/
class Reflection
{
	/**
	Sets the value of a property, calling it's setter if present and of 
	the format set_property (haxe 208 only).

	For Haxe 209 or greater use Reflect.setProperty
	
	@param object		the object to set the property on
	@param property 	the property to set
	@param value 		the new value of the property
	@return the new value of the property
	*/
	public static function setProperty(object:Dynamic, property:String, value:Dynamic):Dynamic
	{
		Reflect.setProperty(object, property, value);
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
	@throws ArgumentException is Reflect.callMethod fails
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
				throw new Exception("Error calling method " + Type.getClassName(Type.getClass(o)) + "." + func + "(" + args.toString() + ")",e);
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
						throw new Exception("Error calling method " + Type.getClassName(Type.getClass(o)) + "." + func + "(" + args.toString() + ")",e);
					}
				}
				attempts ++;
				args.push(null);
			}
			while (attempts < 10);

			throw new ArgumentException("Unable to call " + Type.getClassName(Type.getClass(o)) + "." + func + "(" + args.toString() + ")");
					
			
			return null;
		#end
	}

}
