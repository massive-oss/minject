/*
Copyright (c) 2012 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

import mtask.target.HaxeLib;
import mtask.target.Web;
import mtask.target.Flash;
import mtask.target.Directory;

class Build extends mtask.core.BuildBase
{
	public function new()
	{
		super();
	}

	@target function haxelib(target:HaxeLib)
	{
		target.url = "http://github.com/massiveinteractive/minject";
		target.description = "A Haxe port of the ActionScript 3 SwiftSuspenders IOC library with efficient macro enhanced type reflection. Supports AVM1, AVM2, JavaScript, Neko and C++.";
		target.versionDescription = "Removed inline mcore/mdata classes, added dependencies.";

		target.addTag("cross");
		target.addTag("utility");
		target.addTag("massive");
		
		target.afterCompile = function(path)
		{
			cp("src/*", path);
		}
	}

	@target function example(t:Directory)
	{
		t.beforeCompile = function(path)
		{
			cp("example/*", path);
		}
	}
	
	@target("example/web") function exampleWeb(t:Web) {}
	@target("example/flash") function exampleFlash(t:Flash) {}

	@task function release()
	{
		invoke("clean");
		invoke("test");
		invoke("build haxelib");
		invoke("build example");
	}

	@task function test()
	{
		cmd("haxelib", ["run", "munit", "test", "-coverage"]);
	}
}
