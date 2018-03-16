package hex.compiletime.basic;

import hex.compiletime.basic.CompileTimeFastEval;
import hex.core.ICoreFactory;
import hex.di.IDependencyInjector;
import hex.error.IllegalArgumentException;
import hex.error.NoSuchElementException;
import hex.runtime.basic.ICoreFactoryListener;
import hex.util.Stringifier;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeCoreFactory implements ICoreFactory
{
	public var trigger (default, never) : _Trigger = new _Trigger();
	var _map 					: Map<String, {}>;

	static var _fastEvalMethod : Dynamic->String->ICoreFactory->Dynamic = CompileTimeFastEval.fromTarget;
	
	public function new() 
	{
		this._map 					= new Map();
	}
	
	public function getInjector() : IDependencyInjector 
	{
		return null;
	}
	
	public function clear() : Void 
	{
		this._map = new Map();
	}
	
	public function keys() : Array<String> 
	{
		var a = [];
		var it = this._map.keys();
		while ( it.hasNext() ) a.push( it.next() );
		return a;
	}
	
	public function values() : Array<Dynamic> 
	{
		var a = [];
		var it = this._map.iterator();
		while ( it.hasNext() ) a.push( it.next() );
		return a;
	}
	
	public function isRegisteredWithKey( key : Dynamic ) : Bool 
	{
		return this._map.exists( key );
	}
	
	public function isInstanceRegistered( instance : Dynamic ) : Bool
	{
		return this.values().indexOf( instance ) != -1;
	}
	
	public function locate( key: String ) : Dynamic 
	{
		if ( this._map.exists( key ) )
        {
            return this._map.get( key );
        }
        else if ( key.indexOf(".") != -1 )
        {
            var props : Array<String> = key.split( "." );
			var baseKey : String = props.shift();
			if ( this._map.exists( baseKey ) )
			{
				var target : Dynamic = this._map.get( baseKey );
				return this.fastEvalFromTarget( target, props.join(".") );
			}
        }
		
		throw new NoSuchElementException( "Can't find item with '" + key + "' key in " + Stringifier.stringify(this) );
	}
	
	public function register( key : String, element : Dynamic ) : Bool 
	{
		if ( !this._map.exists( key ) )
		{
			this._map.set( key, element ) ;
			//Find a fix to remove cast for typedef
			(cast this.trigger).onRegister( key, element );
			return true ;
		}
		else
		{
			throw new IllegalArgumentException( "register(" + key + ", " + element + ") fails, key is already registered." );
		}
	}
	
	public function unregisterWithKey( key : String ) : Bool
	{
		if ( this._map.exists( key ) )
		{
			var instance : Dynamic = this._map.get( key );
			this._map.remove( key ) ;
			//Find a fix to remove cast for typedef
			(cast this.trigger).onUnregister( key ) ;
			return true ;
		}
		else
		{
			return false ;
		}
	}
	
	public function unregister( instance : Dynamic ) : Bool 
	{
		var key : String = this.getKeyOfInstance( instance );
		return ( key != null ) ? this.unregisterWithKey( key ) : false;
	}
	
	public function getKeyOfInstance( instance : Dynamic ) : String
	{
		var iterator = this._map.keys();
		while( iterator.hasNext() )
		{
			var key = iterator.next();
			if ( this._map.get( key ) == instance ) 
			{
				return key;
			}
		}

		return null;
	}
	
	public function add( map : Map<String, Dynamic> ) : Void 
	{
		var iterator = map.keys();

        while( iterator.hasNext() )
        {
            var key : String = iterator.next();
			try
			{
				this.register( key, map.get( key ) );
			}
			catch ( e : IllegalArgumentException )
			{
				e.message = this + ".add() fails. " + e.message;
				throw( e );
			}
        }
	}
	
	public function addListener( listener : ICoreFactoryListener ) : Bool
    {
		return this.trigger.connect( listener );
    }

    public function removeListener( listener : ICoreFactoryListener ) : Bool
    {
		return this.trigger.disconnect( listener );
    }
	
	public function fastEvalFromTarget( target : Dynamic, toEval : String ) : Dynamic
	{
		return CompileTimeCoreFactory._fastEvalMethod( target, toEval, this );
	}
	
	static public function setFastEvalMethod( method : Dynamic->String->ICoreFactory->Dynamic ) : Void
	{
		CompileTimeCoreFactory._fastEvalMethod = method;
	}
}

private class _Trigger
{
	var _inputs : Array<ICoreFactoryListener>;
	
	public function new() 
	{
		this._inputs = [];
	}

	public function connect( input : ICoreFactoryListener ) : Bool
	{
		if ( this._inputs.indexOf( input ) == -1 )
		{
			this._inputs.push( input );
			return true;
		}
		else
		{
			return false;
		}
	}

	public function disconnect( input : ICoreFactoryListener ) : Bool
	{
		var index = this._inputs.indexOf( input );
		if ( index > -1 )
		{
			this._inputs.splice( index, 1 );
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public function disconnectAll() : Void
	{
		this._inputs = [];
	}
	
	function onRegister( key : String, value : Dynamic ) : Void
		for ( input in this._inputs ) input.onRegister( key, value );
	
    function onUnregister( key : String ) : Void
		for ( input in this._inputs ) input.onUnregister( key );
}