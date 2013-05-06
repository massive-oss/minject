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

package mdata;

import mcore.util.Arrays;

/**
Cross platform dictionary class (object to object map) leveraging the native 
dictionary class for flash9 targets.

This supports both objects and primitives as keys, unlike haxe.ds.ObjectMap
which does not support primitive keys on some platforms.
*/
class Dictionary<K, V>
{
	#if flash9
	var map:flash.utils.Dictionary;
	#else
	var _keys:Array<K>;
	var _values:Array<V>;
	#end
	
	public var weakKeys(default, null):Bool;

	/**
	@param weakKeys non functional in JavaScript. Included to maintain 
	consistency with flash dictionary API.
	*/
	public function new(?weakKeys:Bool=false)
	{
		this.weakKeys = weakKeys;
		clear();
	}

	/**
	Sets a key value pair. Updates value if key already exists, otherwise adds 
	to registry
	
	@param key The key to set.
	@param value The value to set.
	*/
	public function set(key:K, value:V):Void
	{
		#if flash9
		untyped map[key] = value;
		#else
		for (i in 0..._keys.length)
		{
			if (_keys[i] == key)
			{
				_keys[i] = key;
				_values[i] = value;
				return;
			}
		}

		_keys.push(key);
		_values.push(value);
		#end
	}

	/**
	Returns value for key or null if not registered.
	
	Note that a return value of null does not necessarily mean that the key does not exist as a
	value of null can be registered against a key. The safe option is to check 
	using dictionary.exists(key).
	
	@param key The key to return
	@return The value for key, or null if not found.
	*/
	public function get(key:K):V
	{
		#if flash9
		return untyped map[key];
		#else
		for (i in 0..._keys.length)
		{
			if (_keys[i] == key)
			{
				return _values[i];
			}
		}
		return null;
		#end
	}

	/**
	Removes a key/value from the Dictionary.
	
	@param key The key to delete.
	@return True if the remove was successful, false if the key was not found.
	*/
	public function remove(key:K):Bool
	{
		#if flash9
		var e = exists(key);
		untyped __delete__(map, key);
		return e;
		#else
		for (i in 0..._keys.length)
		{
			if (_keys[i] == key)
			{
				_keys.splice(i, 1);
				_values.splice(i, 1);
				return true;
			}
		}
		return false;
		#end
	}

	/**
	Removes a key/value from the Dictionary.
	
	@deprecated Use remove(key) instead.
	
	@param key The key to delete.
	*/
	public function delete(key:K):Void
	{
		remove(key);
	}

	/**
	Returns true if key is registered.
	
	@param key The key to check for.
	@return A boolean indicating the presence of the key.
	*/
	public function exists(key:K)
	{
		#if flash9
		return untyped __in__(key, map);
		#else
		for (k in _keys)
		{
			if (k == key)
			{
				return true;
			}
		}
		return false;
		#end
	}

	/**
	Clear all keys and values from the Dictionary. 
	*/
	public function clear()
	{
		#if flash9
		map = new flash.utils.Dictionary(weakKeys);
		#else
		_keys = [];
		_values = [];
		#end
	}

	/**
	Returns array of registered keys.
	
	@return An array of keys.
	*/
	public function keys():Iterator<K>
	{
		#if flash9
		return untyped __keys__(map).iterator();
		#else
		return _keys.iterator();
		#end
	}

	/**
	Returns iterator of registered values.
	
	@return An iterator over the values.
	*/
	public function iterator():Iterator<V>
	{
		#if flash9
		var values = [];
		for (k in keys())
			values.push(get(k));
		return values.iterator();		
		#else
		return _values.iterator();
		#end
	}

	/**
	Returns the string representation of the keys and values in this Dictionary.
	*/
	public function toString():String
	{
		var s = "{";
		
		for (key in keys())
		{
			var value = get(key);
			var k:String = Std.is(key, Array) ? "[" + Arrays.toString(cast key) + "]" : Std.string(key);
			var v:String = Std.is(value, Array) ? "[" + Arrays.toString(cast value) + "]" : Std.string(value);
			s += k + " => " + v + ", ";
		}
		
		if (s.length > 2)
			s = s.substr(0, s.length - 2);
		
		return s + "}";
	}
}
