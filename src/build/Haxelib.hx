// See the file "LICENSE" for the full license governing this code

import sys.io.File;

import haxe.Json;
import haxe.macro.Context;

import mdk.sys.SysApi;

class Haxelib
{
	static function run()
	{
		var jsonPath = 'haxelib.json';

		var json = Json.parse(File.getContent(jsonPath));
		var info = Json.parse(File.getContent('mdk/info.json'));
		json.version = info.version;
		File.saveContent(jsonPath, Json.stringify(json, null, '\t') + '\n');

		var path = Context.definedValue('output');
		SysApi.createDirectory(path);
		SysApi.copy('LICENSE', '$path/LICENSE');
		SysApi.copy('src/lib', '$path/src/lib');
		SysApi.copy(jsonPath, '$path/$jsonPath');
		SysApi.zip(path, '$path.zip', '$path/');
	}
}
