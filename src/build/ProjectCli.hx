import sys.io.File;
import haxe.Json;

import mdk.sys.SysApi;
import mdk.lib.LibProject;

/**
	Release tasks for the MDK
**/
class ProjectCli extends mdk.cli.CliModule
{
	public function new() super();

	@task function buildHaxelib()
	{
		var jsonPath = 'haxelib.json';

		var json = Json.parse(File.getContent(jsonPath));
		json.version = LibProject.current.version.toString();
		File.saveContent(jsonPath, Json.stringify(json, null, '\t') + '\n');

		var path = 'bin/haxelib';
		SysApi.createDirectory(path);
		SysApi.copy('src/lib', '$path/src/lib');
		SysApi.copy(jsonPath, '$path/$jsonPath');
		SysApi.zip(path, '$path.zip', '$path/');
	}

	@task function buildExample()
	{
		var path = 'bin/example';
		SysApi.createDirectory(path);
		SysApi.copy('src/example', '$path/src');
		SysApi.zip(path, '$path.zip', '$path/');
	}
}
