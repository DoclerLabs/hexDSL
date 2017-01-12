package hex.core;

#if macro
import haxe.macro.Context;
#else
import hex.error.IllegalArgumentException;
#end

/**
 * ...
 * @author Francis Bourre
 */
class SymbolTable
{
	var _map : Map<String, Bool>;

	public function new()
	{
		this._map = new Map<String, Bool>();
	}

	public function isRegistered( id : String ) : Bool
	{
		return this._map.exists( id );
	}

	public function clear() : Void
	{
		this._map = new Map<String, Bool>();
	}

	public function register( id : String ) : Bool
	{
		if ( this._map.exists( id ) )
		{
			var errorMessage = "Registration failed. '" + id + "' is already registered in this symbol table";
			
			#if macro
			Context.error( errorMessage, Context.currentPos() );
			#else
			throw new IllegalArgumentException( errorMessage );
			#end

		} else
		{
			this._map.set( id, true );
			return true;
		}

		return false;
	}

	public function unregister( id : String ) : Bool
	{
		if ( this.isRegistered( id ) )
		{
			this._map.remove( id );
			return true;
		}
		else
		{
			var errorMessage = "Unregistration failed with id '" + id + "'";
			
			#if macro
			Context.error( errorMessage, Context.currentPos() );
			#else
			throw new IllegalArgumentException( errorMessage );
			#end
		}

		return false;
	}
}