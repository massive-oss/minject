// See the file "LICENSE" for the full license governing this code

package minject.support.injectees.childinjectors;

class LeftRobotFoot extends RobotFoot
{
	@inject
	public function new(?toes:RobotToes=null)
	{
		super(toes);
	}
}
