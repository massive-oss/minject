package minject;

import Map;

class ClassMap<V> implements IMap<Class<Dynamic>, V>
{
	var map:Map<String, V>;

	public function new()
	{
		map = new Map();
	}

	public function get(k:Class<Dynamic>):Null<V>
	{
		return map.get(getKey(k));
	}

	public function set(k:Class<Dynamic>, v:V):Void
	{
		map.set(getKey(k), v);
	}

	public function exists(k:Class<Dynamic>):Bool
	{
		return map.exists(getKey(k));
	}

	public function remove(k:Class<Dynamic>):Bool
	{
		return map.remove(getKey(k));
	}

	public function keys():Iterator<Class<Dynamic>>
	{
		return cast [for (k in map.keys()) Type.resolveClass(k)].iterator();
	}

	public function iterator():Iterator<V>
	{
		return map.iterator();
	}

	public function toString()
	{
		return map.toString();
	}

	inline function getKey(k:Class<Dynamic>)
	{
		return Type.getClassName(k);
	}
}
