## Overview

minject is a metadata driven inversion of control (IOC) solution for Haxe. It has been thoroughly tested on JS, AVM1/2, PHP and Neko, but should also work on other platforms.

This documentation is a modified version of the original, which can be
found [here](https://github.com/tschneidereit/SwiftSuspenders/blob/the-past/README.textile).

## Features

minject supports the following features as described in more details later in
the documentation:

* metadata based annotation of injection points
* injecting into:
    * properties
    * methods (with support for optional arguments)
    * constructors (with support for optional arguments)

* named injections, allowing for more specific binding of injections than just
by their type. (See "defining injection points")
* @post annotations for invoking methods after all injections have been applied
* mapping:
    * values of nearly any type (enums, abstracts, typedefs, functions)
    * classes (of which new instances are created for each injection)
    * singletons (which are created lazily on first injection and then reused for each additional injection of the same rule)
    * rules (which allows sharing singletons between multiple mapping rules)

* creating child injectors which share their parents' injection mappings but can define additional mappings complementing or replacing the parents' ones
* querying for the existence of injection rules using Injector#hasMapping
* direct application of injection rules using Injector#getInstance

## Installation

	haxelib install minject

## Usage

You can find an example of minject usage [here](https://github.com/massiveinteractive/minject/blob/master/src/example)

### Defining dependencies

minject supports three types of dependency definitions:
* *value bindings*, which simply map an injection request to be satisfied by
  injecting the given value
* *class bindings*, which map an injection request to be satisfied by injecting
  a new instance of the given class
* *singleton bindings*, which map all injection requests for the given class by
  injecting the same shared instance, which itself gets created on first request

Additionally, it's possible to re-use dependency mappings with `mapRule`.

For all definition types, it's possible to specify names, which allows using
multiple injection bindings to the same class.

### Defining injection points

Dependency bindings can be injected into an object using constructor, setter,
property or method injection (or a combination of these).
Constructor, Setter, property and method injection require metadata for all
injections to be added to the injectee class.

	@inject

and for injecting named dependencies

	@inject('NamedDependency')

When using basic constructor injections

	@inject public function new(foo:Bar, beautiful:Flower) { ... }

When using named dependencies for constructor injection, the metadata has to be
placed before the constructor method.

	@inject('NamedDependency') public function new(foo:Bar) { ... }

For methods and constructors accepting multiple parameters, it's possible to
define mixes of named and unnamed dependency bindings. In this case, trailing
unnamed dependencies can simply be omitted in the metadata, whereas unnamed
dependencies followed by named ones have to be declared as the empty string:

	@inject('', 'NamedDependency')

For methods and constructors, only the mandatory arguments have to have
injection mappings. Optional arguments are added in order as long as a mapping
is available for them.

Injection points apply to inheriting classes just as they do to the class they
are defined for. Thus, it's possible to define injection points for a base
class and use them with all derived classes (which in turn might specify
additional injection points).

### Post construct: Automatically invoking methods on injection completion

Instances of classes that depend on automatic DI are only ready to be used
after the DI has completed. Annotating methods in the injectee class with the
`@post` metadata causes them to be invoked directly after all injections have
completed and it is safe to use the instance. Multiple methods can be invoked
in a defined order by specifying a priority: `@post(2)`.

### Querying for injection mapping existence

minject supports querying for the existence of mapping rules for any request
using `Injector#hasMapping`.

`hasMapping` expects a class or an interface and optionally a name for the
mapping and returns `true` if a request for this class/name combination can be
satisfied. Otherwise, it returns `false`.

### Directly applying injection mappings

minject supports directly applying injection mappings using `Injector#getInstance`.
`getInstance` expects a class or an interface and optionally a name for the
mapping and returns the mapping's result if one is defined. Otherwise, an
exception is thrown.

The returned value depends on the mapping defined for the relevant request.
E.g., if a singleton mapping has been defined for the request, the shared
singleton instance will be returned instead of creating a new instance of the
class.

### Error handling

If a mapping for a requested injection is not found, an exception string
containing the target class and the requested property type is thrown.

### Child Injectors

minject supports creating child injectors. These are dependent on their parent
injector and automatically inherit all rule mappings the parent has.
Additionally, they can have their own rule mappings, complementing or
overriding the parent mappings.

The main use-case for this feature is as a solution to the so-called "robot
legs problem". When using Dependency Injection, one often wants to create very
similar object trees that have only slight differences. A good illustration is
a simplified robot, that can be built using identical parts for its legs but
needs different parts for the left and the right foot. Using normal Dependency
Injection, one would have to subclass the RobotLeg class for each leg only to
enable specifying different injections for each foot. The subclasses would then
have to implement boilerplate code to apply the injection to the variable the
parent expects the foot in:

	class Robot
	{
		@inject public var leftLeg:LeftRobotLeg;
		@inject public var rightLeg:RightRobotLeg;
	}

	class RobotLeg
	{
		var foot:RobotFoot;
	}

	class LeftRobotLeg extends RobotLeg
	{
		@inject public var foot:LeftRobotFoot;
	}

	class RightRobotLeg extends RobotLeg
	{
		@inject public var foot:RightRobotFoot;
	}

	class RobotConstruction
	{
		function buildRobot()
		{
			var injector = new Injector();
			injector.map(LeftRobotLeg).toClass(LeftRobotLeg);
			injector.map(RightRobotLeg).toClass(RightRobotLeg);
			injector.map(LeftRobotFoot).toClass(LeftRobotFoot);
			injector.map(RightRobotFoot).toClass(RightRobotFoot);
			var robot = injector.instantiate(Robot);
		}
	}

Using child injectors, the robot can be built with just the RobotLeg class,
while still supplying different feet for each leg:

	public class Robot
	{
		@inject('leftLeg') public var leftLeg:RobotLeg;
		@inject('rightLeg') public var rightLeg:RobotLeg;
	}

	public class RobotLeg
	{
		var foot:RobotFoot;
	}

	public class RobotConstruction
	{
		function buildRobot()
		{
			var injector = new Injector();

			// store a reference to the rule
			var leftLegRule = injector.map(RobotLeg, 'leftLeg').toClass(RobotLeg);

			// create a child injector
			var leftLegInjector = injector.createChildInjector();

			// create a mapping for the correct foot in the child injector
			leftLegInjector.map(RobotFoot).toClass(LeftRobotFoot);

			// instruct SwiftSuspenders to use the child injector for all
			// dependency injections in the left leg object tree
			leftLegRule.setInjector(leftLegInjector);

			// and the same for the right leg:
			var rightLegInjector = injector.createChildInjector();
			rightLegInjector.map(RobotFoot).toClass(RightRobotFoot);
			rightLegRule.setInjector(rightLegInjector);

			// finally, create the object tree by instantiating the Robot class:
			var robot = injector.instantiate(Robot);
		}
	}

The child injectors forward all injection requests they don't have a mapping
for to their parent injector. This enables sharing additional rules between the
injectors. For example, the robot feet might have toes that work the same for
both feet, so a mapping for these could be added to the main injector instead
of adding the mappings to both child injectors.

If a mapping from a parent (or other ancestor) injector is used, that doesn't
mean that the child injector isn't used for subsequent injections anymore.
I.e., you can have "holes" in your child injector's mappings that get filled
by an ancestor injector and still define other mappings in your child injector
that you want to have applied later on in the object tree that is constructed
through DI.

Injectors can be nested freely to create configuration trees of
arbitrary complexity.

### Examples

#### Field and Setter Injection

Suppose you have a class into which you want to inject dependencies that looks
like this (Note that I've left out import statements for brevity):

	class MyDependentClass
	{
		@inject public var firstDepency:MovieClip;

		@inject('currentTime') public var secondDependency:Date;

		@inject public var thirdDependency(default, set_thirdDependency):Sprite

		function set_thirdDependency(value:Sprite):Sprite
		{
			return thirdDependency = value;
		}
	}

To inject dependencies into an instance of this class, you would first define
dependency mappings and then invoke `Injector#injectInto`:

	var injector = new Injector();
	injector.map(MovieClip).toValue(new MovieClip());

	var currentTime = Date.now();
	injector.map(Date, 'currentTime').toValue(currentTime);

	injector.map(Sprite).asSingleton();

	var injectee = new MyDependentClass();
	injector.injectInto(injectee);

#### Method Injection

Suppose you have a class into which you want to inject dependencies that looks
like this (Note that I've left out import statements for brevity):

	class MyDependentClass
	{
		var myMovieClip:MovieClip;
		var currentTime:Date;

		@inject public function setFirstDependency(injection:MovieClip):Void
		{
			myMovieClip = injection;
		}

		@inject('currentTime')
		public function setSecondDependency(injection:Date):Void
		{
			currentTime = injection;
		}

		@inject('','currentTime')
		public function setMultipleDependencies(movieClip:MovieClip, date:Date):Void
		{
			myMovieClip = movieClip;
			currentTime = date;
		}
	}

To inject dependencies into an instance of this class, you would first define
dependency mappings and then invoke `Injector#injectInto`:

	var injector = new Injector();
	injector.map(MovieClip).toValue(new MovieClip());

	var currentTime = Date.now();
	injector.map(Date, 'currentTime').toValue(currentTime);

	var injectee = new MyDependentClass();
	injector.injectInto(injectee);

In this case, the defined dependencies are partly redundant, which is waste -
but otherwise not harmful.

#### Constructor Injection

Suppose you have a class into which you want to inject dependencies that looks
like this (Note that I've left out import statements for brevity):

	class MyDependentClass
	{
		var myMovieClip:MovieClip;
		var currentTime:Date;

		@inject('', 'currentTime') public function new(movieClip:MovieClip, date:Date)
		{
			myMovieClip = movieClip;
			currentTime = date;
		}
	}

To inject dependencies into an instance of this class, you would first define
dependency mappings and then invoke `Injector#instantiate`:

	var injector = new Injector();
	injector.map(MovieClip).toValue(new MovieClip());
	var currentTime = Date.now();
	injector.map(Date, 'currentTime').toValue(currentTime);
	var injectee = injector.instantiate(MyDependentClass);
