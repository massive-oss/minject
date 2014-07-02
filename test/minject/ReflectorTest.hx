/*
Copyright (c) 2012-2014 Massive Interactive

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

import minject.support.types.Class1;
import minject.support.types.Class1Extension;
import minject.support.types.Interface1;

class ReflectorTest
{
	public function new(){}
	
 	static var CLASS1_FQCN_DOT_NOTATION:String = "minject.support.types.Class1";
	static var CLASS_IN_ROOT_PACKAGE:Class<Dynamic> = Date;
	static var CLASS_NAME_IN_ROOT_PACKAGE:String = "Date";
	
	var reflector:Reflector;
	
	@Before
	public function setup():Void
	{
		reflector = new Reflector();
	}
	
	@After
	public function teardown():Void
	{
		reflector = null;
	}
	
	@Test
	public function classExtendsClass():Void
	{
		var isClass = reflector.classExtendsOrImplements(Class1Extension, Class1);
		Assert.isTrue(isClass);//"Class1Extension should be an extension of Class1"
	}
	
	@Test
	public function classExtendsClassFromClassNameWithDotNotation():Void
	{
		var isClass = reflector.classExtendsOrImplements("minject.support.types.Class1Extension", Class1);
		Assert.isTrue(isClass);//"Class1Extension should be an extension of Class1"
	}
	
	@Test
	public function classImplementsInterface():Void
	{
		var isImplemented = reflector.classExtendsOrImplements(Class1, Interface1);
		Assert.isTrue(isImplemented);//"Class1 should implement Interface1"
	}
	
	@Test
	public function classImplementsInterfaceFromClassNameWithDotNotation():Void
	{
		var isImplemented = reflector.classExtendsOrImplements("minject.support.types.Class1", Interface1);
		Assert.isTrue(isImplemented);//"Class1 should implement Interface1"
	}
	
	@Test
	public function getFullyQualifiedClassNameFromClass():Void
	{
		var fqcn = reflector.getFQCN(Class1);
		Assert.areEqual(CLASS1_FQCN_DOT_NOTATION, fqcn);
	}

	@Test
	public function getFullyQualifiedClassNameFromClassString():Void
	{
		var fqcn = reflector.getFQCN(CLASS1_FQCN_DOT_NOTATION);
		Assert.areEqual(CLASS1_FQCN_DOT_NOTATION, fqcn);
	}
	
	@Test
	public function getFullyQualifiedClassNameFromClassInRootPackage():Void
	{
		var fqcn = reflector.getFQCN(CLASS_IN_ROOT_PACKAGE);
		Assert.areEqual(CLASS_NAME_IN_ROOT_PACKAGE, fqcn);
	}

	@Test
	public function getFullyQualifiedClassNameFromClassStringInRootPackage():Void
	{
		var fqcn = reflector.getFQCN(CLASS_NAME_IN_ROOT_PACKAGE);
		Assert.areEqual(CLASS_NAME_IN_ROOT_PACKAGE, fqcn);
	}
}
