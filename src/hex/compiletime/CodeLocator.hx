package hex.compiletime;

import haxe.ds.ObjectMap;
import hex.core.IApplicationAssembler;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class CodeLocator 
{
	static var __M : Map<IApplicationAssembler, ObjectMap<Dynamic, Dynamic>> = new Map();

	function new() {}
	
	static public function get( classReference : Class<Dynamic>, assembler : IApplicationAssembler )
	{
		if ( !__M.exists( assembler ) )
		{
			if ( assembler == null )
			{
				throw new NullPointerException( 'assembler should not be null' );
			}
			else
			{
				__M.set( assembler, new ObjectMap() );
			}
			
		}

		var contextMap = __M.get( assembler );

		if ( !contextMap.exists( classReference ) )
		{
			if ( assembler == null )
			{
				throw new NullPointerException( 'assembler should not be null' );
			}
			else
			{
				var locator = Type.createInstance( classReference, [ assembler ] );
				contextMap.set( classReference, locator );
			}
		}
		
		return contextMap.get( classReference );
	}
}