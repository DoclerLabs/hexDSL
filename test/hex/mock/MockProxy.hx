package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockProxy 
{
	public var scope 						: Dynamic;
	public var callback 					: Dynamic;
	
	public function new( scope : Dynamic, method : Dynamic ) 
	{
		this.scope 				= scope;
		this.callback 			= method;
	}
}