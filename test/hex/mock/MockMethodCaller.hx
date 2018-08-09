package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockMethodCaller 
{
	public static var staticVar : Int = 3;
	
	public var argument : Int;
	
	public function new() 
	{
		
	}
	
	public function call( i : Int ) : Void
	{
		this.argument = i;
	}
}