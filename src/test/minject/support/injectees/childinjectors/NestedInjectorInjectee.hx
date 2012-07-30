/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package minject.support.injectees.childinjectors;

import minject.Injector;

class NestedInjectorInjectee
{
	public function new(){}
	
	@inject
	public var injector: Injector;
	public var nestedInjectee: NestedNestedInjectorInjectee;

	@post
	public function createAnotherChildInjector()
	{
		nestedInjectee = injector.instantiate(NestedNestedInjectorInjectee);
	}
}
