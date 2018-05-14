package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockClass implements IMockInterface implements IAnotherMockInterface
{
	public static var MESSAGE_TYPE = "onMessageType";
	
	public function new() 
	{
		
	}
	
	public function getInfos() : String
	{
		return 'infos';
	}
	
	static public function getInfos2(arg:String) : String
	{
		return 'infos';
	}
}