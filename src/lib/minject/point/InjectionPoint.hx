// See the file "LICENSE" for the full license governing this code

package minject.point;

import minject.Injector;

interface InjectionPoint
{
	public var field(default, null):String;
	function applyInjection(target:Dynamic, injector:Injector):Dynamic;
}
