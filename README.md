minject
=======

A macro enhanced Haxe port of Till Schneidereit's AS3 Swift Suspenders IOC library. Please note that this is a port of SwiftSuspenders v1, as the API has changed significantly in v2.

For more information see [the original documentation](https://github.com/tschneidereit/SwiftSuspenders/blob/the-past/README.textile).

You can download an example of minject usage [here](http://github.com/downloads/massiveinteractive/minject/example.zip).


### Basic Usage

Requests:

	@Inject
	public var foo:Foo;

	@Inject("myBar")
	public var myBar:Bar;


Mapping:

	injector = new Injector();
	injector.mapSingleton(Foo);
	injector.mapClass(Bar, Bar, "myBar");
