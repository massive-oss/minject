// See the file "LICENSE" for the full license governing this code

package minject.support.injectees.childinjectors;

class RobotBody
 {
	public function new(){}

	@inject('leftLeg')
	public var leftLeg:RobotLeg;

	@inject('rightLeg')
	public var rightLeg:RobotLeg;
}
