package hex.mock;

import hex.event.MessageType;

/**
 * ...
 * @author Francis Bourre
 */
class MockClass implements IMockInterface implements IAnotherMockInterface
{
	public static var MESSAGE_TYPE = new MessageType( "onMessageType" );
	
	public function new() 
	{
		
	}
}