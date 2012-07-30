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
The Injector contract.
*/
interface IInjector
{
	/**
	When asked for an instance of the class <code>whenAskedFor</code> 
	inject the instance <code>useValue</code>.
	
	<p>This is used to register an existing instance with the injector 
	and treat it like a Singleton.</p>
	
	@param whenAskedFor A class or interface
	@param useValue An instance
	@param named An optional name (id)
	
	@returns A reference to the rule for this injection. To be used with 
	<code>mapRule</code>
	*/
	function mapValue(whenAskedFor:Class<Dynamic>, useValue:Dynamic, ?named:String = ""):Dynamic;
	
	/**
	When asked for an instance of the class <code>whenAskedFor</code> 
	inject a new instance of <code>instantiateClass</code>.
	
	<p>This will create a new instance for each injection.</p>
	
	@param whenAskedFor A class or interface
	@param instantiateClass A class to instantiate
	@param named An optional name (id)

	@returns A reference to the rule for this injection. To be used with 
	<code>mapRule</code>
	*/
	function mapClass(whenAskedFor:Class<Dynamic>, instantiateClass:Class<Dynamic>, ?named:String = ""):Dynamic;
	
	/**
	When asked for an instance of the class <code>whenAskedFor</code> 
	inject an instance of <code>whenAskedFor</code>.
	
	<p>This will create an instance on the first injection, but will 
	re-use that instance for subsequent injections.</p>
	
	@param whenAskedFor A class or interface
	@param named An optional name (id)
	
	@returns A reference to the rule for this injection. To be used with 
	<code>mapRule</code>
	*/
	function mapSingleton(whenAskedFor:Class<Dynamic>, ?named:String = ""):Dynamic;
	
	
	/**
	When asked for an instance of the class <code>whenAskedFor</code>
	inject an instance of <code>useSingletonOf</code>.
	
	<p>This will create an instance on the first injection, but will 
	re-use that instance for subsequent injections.</p>
	
	@param whenAskedFor A class or interface
	@param useSingletonOf A class to instantiate
	@param named An optional name (id)
	
	@returns A reference to the rule for this injection. To be used with 
	<code>mapRule</code>
	*/
	function mapSingletonOf(whenAskedFor:Class<Dynamic>, useSingletonOf:Class<Dynamic>, ?named:String = ""):Dynamic;
	
	/**
	When asked for an instance of the class <code>whenAskedFor</code>
	use rule <code>useRule</code> to determine the correct injection.
	
	<p>This will use whatever injection is set by the given injection 
	rule as created using one of the other mapping methods.</p>
	
	@param whenAskedFor A class or interface
	@param useRule The rule to use for the injection
	@param named An optional name (id)
	
	@returns A reference to the rule for this injection. To be used with 
	<code>mapRule</code>
	*/
	function mapRule(whenAskedFor:Class<Dynamic>, useRule:Dynamic, ?named:String = ""):Dynamic;
	
	/**
	Perform an injection into an object, satisfying all it's dependencies
	
	<p>The <code>IInjector</code> should throw an <code>Error</code> if 
	it can't satisfy all dependencies of the injectee.</p>
	
	@param target The object to inject into - the Injectee
	*/
	function injectInto(target:Dynamic):Void;
	
	/**
	Create an object of the given class, supplying its dependencies as 
	constructor parameters if the used DI solution has support for 
	constructor injection
	
	<p>Adapters for DI solutions that don't support constructor 
	injection should just create a new instance and perform setter 
	and/or method injection on that.</p>
	
	<p>NOTE: This method will always create a new instance. If you need 
	to retrieve an instance consider using <code>getInstance</code></p>
	
	<p>The <code>IInjector</code> should throw an <code>Error</code> if 
	it can't satisfy all dependencies of the injectee.</p>
	
	@param clazz The class to instantiate
	@returns The created instance
	*/
	function instantiate<T>(ofClass:Class<T>):T;
	
	/**
	Create or retrieve an instance of the given class
	
	@param ofClass The class to retrieve.
	@param named An optional name (id)
	@return An instance
	*/		
	function getInstance<T>(ofClass:Class<T>, ?named:String = ""):T;
	
	/**
	Create an injector that inherits rules from its parent
	
	@returns The injector 
	*/		
	function createChildInjector():IInjector;
	
	/**
	Remove a rule from the injector

	@param clazz A class or interface
	@param named An optional name (id)
	*/
	function unmap(clazz:Class<Dynamic>, ?named:String = ""):Void;
	
	/**
	Does a rule exist to satsify such a request?

	@param clazz A class or interface
	@param named An optional name (id)
	@returns Whether such a mapping exists
	*/		
	function hasMapping(clazz:Class<Dynamic>, ?named:String = ""):Bool;
}
