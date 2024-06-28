package util;

class Utils
{
	public static function arrayDuplicates<T>(arr:Array<T>)
	{
		for (i in 0...arr.length)
		{
			for (j in (i + 1)...arr.length)
			{
				if (arr[i] == arr[j])
				{
					return true;
				}
			}
		}
		return false;
	}
}
