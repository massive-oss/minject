/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package minject.support.injectees.childinjectors;

import minject.InjectionConfig;
import minject.Injector;

class InjectorCopyRule extends InjectionConfig
{
	public function new()
	{
		super(Injector, "");
	}

	public override function getResponse(injector:Injector):Dynamic
	{
		return injector.createChildInjector();
	}
}
