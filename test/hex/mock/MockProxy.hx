package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockProxy 
{
	public var scope 						: Dynamic;
	public var callback 					: Void->Dynamic;
	
	public function new( scope : Dynamic, callback : Void->Dynamic ) 
	{
		this.scope 				= scope;
		this.callback 			= callback;
	}
	
	public function call() : Dynamic
	{
		return Reflect.callMethod( this.scope, this.callback, [] );
	}
}