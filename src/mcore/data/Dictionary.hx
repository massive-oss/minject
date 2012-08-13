package mcore.data;

/**
Cross platform dictionary class (object to object map) leveraging the native 
dictionary class for flash9 targets.
*/
#if flash9
typedef Dictionary<K, V> = flash.utils.TypedDictionary<K, V>;
#else
class Dictionary<K, V>
{
	var _keys:Array<K>;
	var _values:Array<V>;

	/**
	@param weakKeys non functional in JavaScript. Included to maintain 
	consistency with flash dictionary API.
	*/
	public function new(?weakKeys:Bool=false)
	{
		_keys = [];
		_values = [];
	}

	/**
	Sets a key value pair. Updates value if key already exists, otherwise adds 
	to registry
	
	@param key The key to set.
	@param value The value to set.
	*/
	public function set(key:K, value:V):Void
	{
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
	}

	/**
	Returns value for key or null if not registered.
	
	@param key The key to return
	@return The value for key, or null if not found.
	*/
	public function get(key:K):V
	{
		for (i in 0..._keys.length)
		{
			if (_keys[i] == key)
			{
				return _values[i];
			}
		}
		return null;
	}

	/**
	Removes a key/value from the registry.
	
	@param key The key to delete.
	*/
	public function delete(key:K)
	{
		for (i in 0..._keys.length)
		{
			if (_keys[i] == key)
			{
				_keys.splice(i, 1);
				_values.splice(i, 1);

				return;
			}
		}
	}

	/**
	Returns true if key is registered.
	
	@param key The key to check for.
	@return A boolean indicating the presence of the key.
	*/
	public function exists(key:K)
	{
		return get(key) != null;
	}

	/**
	Returns array of registered keys.
	
	@return An array of keys.
	*/
	public function keys():Array<K>
	{
		return _keys;
	}

	/**
	Returns iterator of registered keys
	
	@return An iterator for the keys.
	*/
	public function iterator():Iterator<K>
	{
		return _keys.iterator();
	}
}
#end
