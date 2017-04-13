package hex.compiletime;

import hex.core.IApplicationAssembler;
import hex.error.NullPointerException;

/**
 * ...
 * @author Francis Bourre
 */
class CodeLocator 
{
	static var _M : Map<String, Dynamic> = new Map();
	
	function new() {}
	
	static public function get( contextName : String, ?assembler : IApplicationAssembler )
	{
		contextName = 'hex.context.' + contextName;
		
		if ( !_M.exists( contextName ) )
		{
			if ( assembler == null )
			{
				throw new NullPointerException( 'assembler should not be null' );
			}
			else
			{
				var cls = Type.resolveClass( contextName );
				var locator = Type.createInstance( cls, [ assembler ] );
				_M.set( contextName, locator );
			}
		}
		
		return _M.get( contextName );
	}
}