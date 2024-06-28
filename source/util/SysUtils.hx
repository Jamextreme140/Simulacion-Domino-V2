package util;

class SysUtils
{
	public static function createDirIfNotExists(dir:String)
	{
		#if sys
		if (!doesFileExist(dir))
		{
			sys.FileSystem.createDirectory(dir);
		}
		#end
	}

	public static function doesFileExist(path:String):Bool
	{
		#if sys
		return sys.FileSystem.exists(path);
		#else
		return false;
		#end
	}
}
