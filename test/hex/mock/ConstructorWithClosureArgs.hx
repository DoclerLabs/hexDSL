package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class ConstructorWithClosureArgs 
{
	public var f1 : String->String;
	public var f2 : String->String;
	public var f3 : String->String;
	public var f4 : String->String;
	
	public function new( f1 : String->String, f2 : String->String )
	{
		this.f1 = f1;
		this.f2 = f2;
	}
	
	public function callWithClosureArgs( f1 : String->String, f2 : String->String ) : String
	{
		return f1( 'test' ) + f2( 'test' );
	}
	
	static public function staticallWithClosureArgs( f1 : String->String, f2 : String->String ) : String
	{
		return f1( 'test' ) + f2( 'test' );
	}
}