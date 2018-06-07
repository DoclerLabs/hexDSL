package hex.compiletime;

import hex.core.IApplicationAssembler;
import hex.error.NullPointerException;

/**
 * ...
 * @author Francis Bourre
 */
class CodeLocator 
{
	static var __M : Map<IApplicationAssembler, Map<String, Dynamic>> = new Map();

	function new() {}
	
	static public function get( contextName : String, assembler : IApplicationAssembler )
	{
		if ( !__M.exists( assembler ) )
		{
			if ( assembler == null )
			{
				throw new NullPointerException( 'assembler should not be null' );
			}
			else
			{
				__M.set( assembler, new Map() );
			}
			
		}
		
		var contextMap = __M.get( assembler );

		if ( !contextMap.exists( contextName ) )
		{
			if ( assembler == null )
			{
				throw new NullPointerException( 'assembler should not be null' );
			}
			else
			{
				var cls = Type.resolveClass( contextName );
				var locator = Type.createInstance( cls, [ assembler ] );
				contextMap.set( contextName, locator );
			}
		}
		
		return contextMap.get( contextName );
	}
}