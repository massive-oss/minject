/*
* Copyright (c) 2009 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package minject.support.injectees.childinjectors;

class RobotBody
 {
	public function new(){}
	
	@inject("leftLeg")
	public var leftLeg:RobotLeg;
	
	@inject("rightLeg")
	public var rightLeg:RobotLeg;
}
