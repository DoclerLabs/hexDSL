package hex.compiletime;

/**
 * ...
 * @author Francis Bourre
 */
class ContextLocator 
{
	static var _M : Map<String, Dynamic> = new Map();
	
	function new() {}
	
	static public function getContext( contextName : String )
	{
		contextName = 'hex.context.' + contextName;
		
		if ( !_M.exists( contextName ) )
		{
			var cls = Type.resolveClass( contextName );
			var locator = Type.createInstance( cls, [] );
			_M.set( contextName, locator );
		}
		
		return _M.get( contextName );
	}
}