package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockProxy 
{
	public var scope 						: Dynamic;
	public var callback 					: Void->Void;
	
	public function new( scope : Dynamic, method : Void->Void ) 
	{
		this.scope 				= scope;
		this.callback 			= method;
	}
}