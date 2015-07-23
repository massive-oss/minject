// See the file "LICENSE" for the full license governing this code

import sys.io.File;
import haxe.Json;

import mdk.sys.SysApi;
import mdk.lib.LibProject;

class Haxelib
{
	static function main()
	{
		var jsonPath = 'haxelib.json';

		var json = Json.parse(File.getContent(jsonPath));
		json.version = LibProject.current.version.toString();
		File.saveContent(jsonPath, Json.stringify(json, null, '\t') + '\n');

		var path = 'bin/haxelib';
		SysApi.createDirectory(path);
		SysApi.copy('LICENSE', '$path/LICENSE');
		SysApi.copy('src/lib', '$path/src/lib');
		SysApi.copy(jsonPath, '$path/$jsonPath');
		SysApi.zip(path, '$path.zip', '$path/');
	}
}
