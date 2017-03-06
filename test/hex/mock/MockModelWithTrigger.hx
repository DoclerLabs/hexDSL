package hex.mock;

import hex.event.ITrigger;
import hex.event.ITriggerOwner;

/**
 * ...
 * @author Francis Bourre
 */
class MockModelWithTrigger implements ITriggerOwner
{
	public var trigger( default, never )  : ITrigger<IMockTriggerListener>;
	
	public var callbacks( default, never )  : ITrigger<String->Void>;
	
	public function new() 
	{
		
	}
}