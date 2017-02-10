package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockProxy 
{
	public var scope 						: Dynamic;
	public var callback 					: Void->Void;
	
	public function new( scope : Dynamic, callback : Void->Void ) 
	{
		this.scope 				= scope;
		this.callback 			= callback;
	}
}