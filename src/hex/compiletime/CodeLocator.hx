package hex.compiletime;

import haxe.ds.ObjectMap;
import hex.core.IApplicationAssembler;
import hex.error.NullPointerException;

/**
 * ...
 * @author Francis Bourre
 */
/*
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
		trace( contextName );
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