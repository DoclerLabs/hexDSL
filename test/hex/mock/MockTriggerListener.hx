package hex.mock;
import hex.mock.IMockTriggerListener;

/**
 * ...
 * @author Francis Bourre
 */
class MockTriggerListener implements IMockTriggerListener
{
	static public var callbackCount : UInt;
	static public var message		: String;

	public function new() 
	{
		
	}
	
	public function onTrigger( message : String ) : Void
	{
		MockTriggerListener.callbackCount++;
		MockTriggerListener.message = message;
	}
}