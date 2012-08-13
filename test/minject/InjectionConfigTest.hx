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

package minject;

import massive.munit.Assert;

import minject.result.InjectClassResult;
import minject.result.InjectOtherRuleResult;
import minject.result.InjectSingletonResult;
import minject.result.InjectValueResult;
import minject.support.types.Class1;
import minject.support.types.Class1Extension;

class InjectionConfigTest
 {
	public function new(){}
	
	var injector:Injector;
	
	@Before
	public function setup()
	{
		injector = new Injector();
	}

	@After
	public function teardown()
	{
		injector = null;
	}
	
	@Test
	public function configIsInstantiated():Void
	{
		var config = new InjectionConfig(Class1, "");
		Assert.isTrue(Std.is(config, InjectionConfig));
	}
	
	@Test
	public function injectionTypeValueReturnsRespone():Void
	{
		var response = new Class1();
		var config = new InjectionConfig(Class1, "");
		config.setResult(new InjectValueResult(response));
		var returnedResponse = config.getResponse(injector);
		
		Assert.areEqual(response, returnedResponse);
	}
	
	@Test
	public function injectionTypeClassReturnsRespone():Void
	{
		var config = new InjectionConfig(Class1, "");
		config.setResult(new InjectClassResult(Class1));
		var returnedResponse = config.getResponse(injector);
		
		Assert.isTrue(Std.is(returnedResponse, Class1));
	}
	
	@Test
	public function injectionTypeSingletonReturnsResponse():Void
	{
		var config = new InjectionConfig(Class1, "");
		config.setResult(new InjectSingletonResult(Class1));
		var returnedResponse = config.getResponse(injector);

		Assert.isTrue(Std.is(returnedResponse, Class1));
	}
	
	@Test
	public function sameSingletonIsReturnedOnSecondResponse():Void
	{
		var config = new InjectionConfig(Class1, "");
		config.setResult(new InjectSingletonResult(Class1));
		var returnedResponse = config.getResponse(injector);
		var secondResponse = config.getResponse(injector);
		
		Assert.areEqual(returnedResponse, secondResponse);
	}

	@Test
	public function sameNamedSingletonIsReturnedOnSecondResponse():Void
	{
		var config = new InjectionConfig(Class1, "named");
		config.setResult(new InjectSingletonResult(Class1));
		var returnedResponse = config.getResponse(injector);
		var secondResponse = config.getResponse(injector);

		Assert.areEqual(returnedResponse, secondResponse);
	}

	@Test
	public function callingSetResultBetweenUsagesChangesResponse():Void
	{
		var config = new InjectionConfig(Class1, '');
		config.setResult(new InjectSingletonResult(Class1));
		var returnedResponse = config.getResponse(injector);
		config.setResult(null);
		config.setResult(new InjectClassResult(Class1));
		var secondResponse = config.getResponse(injector);

		Assert.isFalse(returnedResponse == secondResponse);
	}

	@Test
	public function injectionTypeOtherRuleReturnsOtherRulesResponse():Void
	{
		var config = new InjectionConfig(Class1, "");
		var otherConfig = new InjectionConfig(Class1Extension, "");
		otherConfig.setResult(new InjectClassResult(Class1Extension));
		config.setResult(new InjectOtherRuleResult(otherConfig));
		var returnedResponse = config.getResponse(injector);

		Assert.isTrue(Std.is(returnedResponse, Class1));
		Assert.isTrue(Std.is(returnedResponse, Class1Extension));
	}
}
