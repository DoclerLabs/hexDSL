package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockReceiver 
{
	public function new() {}

	public function onMessage() : Dynamic
	{
		return this;
	}
}