// See the file "LICENSE" for the full license governing this code

import massive.munit.client.PrintClient;
import massive.munit.client.RichPrintClient;
import massive.munit.client.HTTPClient;
import massive.munit.client.JUnitReportClient;
import massive.munit.client.SummaryReportClient;
import massive.munit.TestRunner;

/**
	Auto generated Test Application.

	Refer to munit command line tool for more information (haxelib run munit)

	#if MCOVER <- hahah
**/
class TestMain
{
	static function main(){	new TestMain(); }

	public function new()
	{
		var suites = new Array<Class<massive.munit.TestSuite>>();
		suites.push(TestSuite);

		var client = new mcover.coverage.munit.client.MCoverPrintClient();
		var httpClient = new HTTPClient(new mcover.coverage.munit.client.MCoverSummaryReportClient());

		var runner:TestRunner = new TestRunner(client);
		runner.addResultClient(httpClient);
		runner.addResultClient(new HTTPClient(new JUnitReportClient()));

		runner.completionHandler = completionHandler;
		runner.run(suites);
	}

	/**
		Updates the background color and closes the current browser for flash and html targets
		(useful for continous integration servers)
	**/
	function completionHandler(successful:Bool):Void
	{
		try
		{
			#if flash
				flash.external.ExternalInterface.call("testResult", successful);
			#elseif js
				js.Lib.eval("testResult(" + successful + ");");
			#elseif (sys||neko||cpp)
				Sys.exit(0);
			#end
		}
		// if run from outside browser can get error which we can ignore
		catch (e:Dynamic)
		{
		}
	}
}
