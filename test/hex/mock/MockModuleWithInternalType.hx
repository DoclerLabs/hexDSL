package hex.mock;

typedef FunctionSignature = String->String;

/**
 * ...
 * @author Francis Bourre
 */
class MockModuleWithInternalType 
{

/*	public function new() 
	{
		
	}*/
	
	
	static public function getInfos2(arg:String) : String
	{
		return 'infos';
	}
}

typedef GetInfosInternalTypedef =
{
	function getInfos() : String;
}
