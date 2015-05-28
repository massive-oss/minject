// See the file "LICENSE" for the full license governing this code

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
		SysApi.copy('LICENSE', '$path/LICENSE');
		SysApi.copy('src/lib', '$path/src/lib');
		SysApi.copy(jsonPath, '$path/$jsonPath');
		SysApi.zip(path, '$path.zip', '$path/');
	}

	@task function buildExample()
	{
		run('mdk', ['build', 'example']);

		var path = 'bin/example';
		SysApi.copy('src/example', '$path/src');
		SysApi.copy('res/example/build.hxml', '$path/build.hxml');
		SysApi.zip(path, '$path.zip', '$path/');
	}
}
