package minject;

import minject.support.types.CustomMetadataClass;
import minject.point.InjectionPoint;
import massive.munit.Assert;

class ExtendedInjectorTest
{
	var injector:ExtendedInjector;

	@Before
	public function before()
	{
		#if macro haxe.macro.Compiler.define("--macro", "minject.RTTI.build('inject','post','CustomMetadata')"); #end

		injector = new ExtendedInjector();
	}

	@Test
	public function should_call_processCustomInjectionPoints_for_classes_declaring_custom_metdata()
	{
		var callbackReceived:Bool = false;

		injector.assertionCallback = function(clazz:Class<Dynamic>, field:String, fieldMeta:Dynamic, injectionPoints:Array<InjectionPoint>)
		{
			callbackReceived = true;

			Assert.areEqual(CustomMetadataClass, clazz);
			Assert.areEqual("customMetadataMethod", field);
			Assert.isTrue(Reflect.hasField(fieldMeta, "CustomMetadata"));
		}

		injector.mapClass(CustomMetadataClass, CustomMetadataClass);
		var instance = injector.instantiate(CustomMetadataClass);

		if(!callbackReceived) Assert.fail("expected processCustomInjectionPoints to be called in the ExtendedInjector");
	}
}

class ExtendedInjector extends Injector
{
	/*
	assign a callback in order to verify arguments passed to <code>processCustomInjectionPoints</code>
	 */
	public var assertionCallback:Class<Dynamic>->String->Dynamic->Array<InjectionPoint>->Void;

	override function processCustomInjectionPoints(clazz:Class<Dynamic>, field:String, fieldMeta:Dynamic, injectionPoints:Array<InjectionPoint>)
	{
		assertionCallback(clazz, field, fieldMeta, injectionPoints);
	}
}
