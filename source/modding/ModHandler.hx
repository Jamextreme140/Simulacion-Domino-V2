package modding;

#if ALLOW_MODDING
import polymod.Polymod;
import polymod.format.ParseRules.TextFileFormat;
import polymod.fs.ZipFileSystem;
import util.SysUtils;

class ModHandler
{
	static final API_VERSION:String = '0.1.0';
	static final MOD_FOLDER:String = 'mods';
	static final CORE_FOLDER:Null<String> = null;
	static var modFileSystem:Null<ZipFileSystem> = null;

	public static var scriptedClasses:Bool = false;
	public static var loadedModIds:Array<String> = [];

	public static function createModRoot():Void
	{
		SysUtils.createDirIfNotExists(MOD_FOLDER);
	}

	public static function loadMods()
	{
		createModRoot();
		loadModsById(getAllModsIds());
	}

	public static function getAllModsIds():Array<String>
	{
		var modIds:Array<String> = [for (i in getAllMods()) i.id];
		return modIds;
	}

	public static function getAllMods():Array<ModMetadata>
	{
		trace('Scanning the mods folder...');

		if (modFileSystem == null)
			modFileSystem = buildFileSystem();

		var modMetadata:Array<ModMetadata> = Polymod.scan({
			modRoot: MOD_FOLDER,
			apiVersionRule: API_VERSION,
			fileSystem: modFileSystem,
			errorCallback: ModErrorHandler.onPolymodError
		});
		trace('Found ${modMetadata.length} mods when scanning.');
		return modMetadata;
	}

	static function loadModsById(ids:Array<String>)
	{
		if (modFileSystem == null)
			modFileSystem = buildFileSystem();

		var loadedModList:Array<ModMetadata> = Polymod.init({
			modRoot: MOD_FOLDER,
			dirs: ids,
			framework: OPENFL,
			apiVersionRule: API_VERSION,
			errorCallback: ModErrorHandler.onPolymodError,
			customFilesystem: modFileSystem,
			parseRules: buildParseRules(),
			useScriptedClasses: scriptedClasses
		});

		if (loadedModList == null)
		{
			trace('An error occurred! Failed when loading mods!');
		}

		loadedModIds = [];
		for (mod in loadedModList)
		{
			trace('  * ${mod.title} v${mod.modVersion} [${mod.id}]');
			loadedModIds.push(mod.id);
		}
	}

	static function buildFileSystem()
	{
		polymod.Polymod.onError = ModErrorHandler.onPolymodError;
		return new ZipFileSystem({
			modRoot: MOD_FOLDER,
			autoScan: true
		});
	}

	static function buildParseRules():polymod.format.ParseRules
	{
		var output:polymod.format.ParseRules = polymod.format.ParseRules.getDefault();
		// Ensure TXT files have merge support.
		output.addType('txt', TextFileFormat.LINES);
		// Ensure script files have merge support.
		output.addType('hscript', TextFileFormat.PLAINTEXT);
		output.addType('hxs', TextFileFormat.PLAINTEXT);
		output.addType('hxc', TextFileFormat.PLAINTEXT);
		output.addType('hx', TextFileFormat.PLAINTEXT);

		// You can specify the format of a specific file, with file extension.
		// output.addFile("data/introText.txt", TextFileFormat.LINES)
		return output;
	}
}
#end
