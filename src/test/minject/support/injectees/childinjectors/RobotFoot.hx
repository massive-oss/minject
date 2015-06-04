// See the file "LICENSE" for the full license governing this code

package minject.support.injectees.childinjectors;

class RobotFoot
{
	public var toes:RobotToes;

	@inject
	public function new(?toes:RobotToes=null)
	{
		this.toes = toes;
	}
}
