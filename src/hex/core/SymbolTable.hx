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
		this._map = new Map();
	}

	public function isRegistered( id : String ) : Bool
	{
		return this._map.exists( id );
	}

	public function clear() : Void
	{
		this._map = new Map();
	}

	public function register( id : String, ?pos : haxe.macro.Expr.Position ) : Void
	{
		if ( this._map.exists( id ) )
		{
			var errorMessage = "Registration failed. '" + id + "' is already registered in this symbol table";
			
			#if macro
			Context.error( errorMessage, pos!=null?pos:Context.currentPos() );
			#else
			throw new IllegalArgumentException( errorMessage );
			#end

		} else
		{
			this._map.set( id, true );
		}
	}

	public function unregister( id : String, ?pos : haxe.macro.Expr.Position ) : Void
	{
		if ( this.isRegistered( id ) )
		{
			this._map.remove( id );
		}
		else
		{
			var errorMessage = "Unregistration failed with id '" + id + "'";
			
			#if macro
			Context.error( errorMessage, pos!=null?pos:Context.currentPos() );
			#else
			throw new IllegalArgumentException( errorMessage );
			#end
		}
	}
}