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
The Reflector contract
*/
interface IReflector
{
	/**
	Does this class or class name implement this superclass or interface?
	
	@param classOrClassName
	@param superclass
	@returns Boolean
	*/
	function classExtendsOrImplements(classOrClassName:Dynamic, superclass:Class<Dynamic>):Bool;
	
	/**
	Get the class of this instance
	
	@param value The instance
	@returns Class
	*/
	function getClass(value:Dynamic):Class<Dynamic>;
	
	/**
	Get the Fully Qualified Class Name of this instance, class name, or class
	
	@param value The instance, class name, or class
	@returns The Fully Qualified Class Name
	*/
	function getFQCN(value:Dynamic):String;
}
