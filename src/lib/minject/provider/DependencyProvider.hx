// See the file "LICENSE" for the full license governing this code

package minject.provider;

import minject.Injector;

interface DependencyProvider<T>
{
	function getValue(injector:Injector):T;
	#if debug
	function toString():String;
	#end
}
