package minject;

class RequestHasher
{
	public static function resolveRequest(forClass:Class<Dynamic>, ?named:String=''):String
	{
		return '${getClassName(forClass)}#${named}';
	}

	public static function getClassName(forClass:Class<Dynamic>):String
	{
		if (forClass == null) return 'Dynamic';
		else return Type.getClassName(forClass);
	}

}