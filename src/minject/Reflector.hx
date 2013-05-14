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

package minject;

/**
	A utility class for reflection.
**/
class Reflector
{
	public function new(){}

	/**
		Does the class specified by classOrClassName implement this superclass 
		or interface?
		
		@param classOrClassName
		@param superclass
		@returns Boolean
	**/
	public function classExtendsOrImplements(classOrClassName:Dynamic, superClass:Class<Dynamic>):Bool
	{
		var actualClass:Class<Dynamic> = null;
		
		if (Std.is(classOrClassName, Class))
		{
			actualClass = cast(classOrClassName, Class<Dynamic>);
		}
		else if (Std.is(classOrClassName, String))
		{
			try
			{
				actualClass = Type.resolveClass(cast(classOrClassName, String));
			}
			catch (e:Dynamic)
			{
				throw "The class name " + classOrClassName + " is not valid because of " + e + "\n" + e.getStackTrace();
			}
		}

		if (actualClass == null)
		{
			throw "The parameter classOrClassName must be a Class or fully qualified class name.";
		}

		var classInstance = Type.createEmptyInstance(actualClass);
		return Std.is(classInstance, superClass);
	}

	/**
		Get the class of this instance
		
		@param value The instance
		@returns Class
	**/
	public function getClass(value:Dynamic):Class<Dynamic>
	{
		if (Std.is(value, Class)) return value;
		return Type.getClass(value);
	}
	
	/**
		Get the fully qualified class name of this instance, class name, or class
		
		@param value The instance, class name, or class
		@returns The Fully Qualified Class Name
	**/
	public function getFQCN(value:Dynamic):String
	{
		var fqcn:String;

		if (Std.is(value, String))
		{
			return cast(value, String);
		}

		return Type.getClassName(value);
	}
}
