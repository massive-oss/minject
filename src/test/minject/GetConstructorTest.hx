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

class GetConstructorTest
 {
	public function new(){}
	
	@Test
	public function passingTest()
	{
		// leving these tests in here lest we need a similar API for low level types.
		Assert.isTrue(true);
	}
	/*
	@Test
	public function getConstructorReturnsConstructorForObject() : Void
	{
		var object: Dynamic = {};
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, Object);
	}

	@Test
	public function getConstructorReturnsConstructorForArray() : Void
	{
		var array: Array<Dynamic> = [];
		var objectClass: Class<Dynamic> = getConstructor(array);
		Assert.assertEquals('object\'s constructor is Object', objectClass, Array);
	}

	@Test
	public function getConstructorReturnsConstructorForBoolean() : Void
	{
		var object: Bool = true;
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, Boolean);
	}

	@Test
	public function getConstructorReturnsConstructorForNumber() : Void
	{
		var object: Float = 10.1;
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, Number);
	}

	@Test
	public function getConstructorReturnsConstructorForInt() : Void
	{
		var object: Int = 10;
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, int);
	}

	@Test
	public function getConstructorReturnsConstructorForUint() : Void
	{
		var object = 10;
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, int);
	}

	@Test
	public function getConstructorReturnsConstructorForString() : Void
	{
		var object: String = 'string';
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, String);
	}

	@Test
	public function getConstructorReturnsConstructorForXML() : Void
	{
		var object:Xml = new XML();
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, XML);
	}

	@Test
	public function getConstructorReturnsConstructorForXMLList() : Void
	{
		var object: XMLList = new XMLList();
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, XMLList);
	}

	@Test
	public function getConstructorReturnsConstructorForFunction() : Void
	{
		var object: Dynamic = function() : Void {};
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, Function);
	}

	@Test
	public function getConstructorReturnsConstructorForRegExp() : Void
	{
		var object: EReg = ~/./;
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, RegExp);
	}

	@Test
	public function getConstructorReturnsConstructorForDate() : Void
	{
		var object: Date = new Date();
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, Date);
	}

	@Test
	public function getConstructorReturnsConstructorForError() : Void
	{
		var object: Error = new Error();
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, Error);
	}

	@Test
	public function getConstructorReturnsConstructorForQName() : Void
	{
		var object: QName = new QName();
		var objectClass: Class<Dynamic> = getConstructor(object);
		Assert.assertEquals('object\'s constructor is Object', objectClass, QName);
	}

	@Test
	public function getConstructorReturnsConstructorForVector() : Void
	{
		var object : Vector.<String> = new Vector.<String>();
		var objectClass: Class<Dynamic> = getConstructor(object);
		//See comment in getConstructor for why Vector.<*> is expected.
		Assert.assertEquals('object\'s constructor is Object', objectClass, Vector.<*>);
	}
	*/
}
