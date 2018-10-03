package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockProvider 
{
	public function new() 
	{
		
	}
	
	public function getBool( b : Bool ) return b;
	public static function getString( s : String ) return s;
	
	public function proxyValue<T>( v : T ) return v;
}