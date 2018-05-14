package hex.core;

import hex.core.IApplicationContext;
import hex.core.ICoreFactory;
import hex.di.IDependencyInjector;
import hex.error.IllegalStateException;
import hex.error.VirtualMethodException;
import hex.log.ILogger;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractApplicationContext implements IApplicationContext
{
	var _name 					: String;
	var _coreFactory 			: ICoreFactory;
	
	public function new( coreFactory : ICoreFactory, name : String ) 
	{
		this._coreFactory	= coreFactory;
		this._name			= name;
	}
	
	public function getName() : String
	{
		return this._name;
	}
	
	public function getCoreFactory() : ICoreFactory 
	{
		return this._coreFactory;
	}
	
	public function getInjector() : IDependencyInjector 
	{
		return this._coreFactory.getInjector();
	}
	
	public function getLogger() : ILogger
	{
		throw new VirtualMethodException();
	}
	
	@:final 
	public function initialize( context : IApplicationContext ) : Void
	{
		if ( !this.isInitialized )
		{
			this._onInitialisation();
			this.isInitialized = true;
		}
		else
		{
			throw new IllegalStateException( "initialize can't be called more than once." );
		}
	}
	
	@:final 
	public function release() : Void
	{
		if ( !this.isReleased )
		{
			this.isReleased = true;
			this._onRelease();
		}
		else
		{
			throw new IllegalStateException( this + ".release can't be called more than once." );
		}
	}
	
	/**
	 * Override and implement
	 */
	function _onInitialisation() : Void
	{

	}

	/**
	 * Override and implement
	 */
	function _onRelease() : Void
	{

	}
	
	/**
	 * Accessor for context initialisation state
	 * @return <code>true</code> if the module is initialized
	 */
	@:isVar public var isInitialized( get, null ) : Bool;
	@:final 
	function get_isInitialized() : Bool
	{
		return this.isInitialized;
	}

	/**
	 * Accessor for context release state
	 * @return <code>true</code> if the module is released
	 */
	@:isVar public var isReleased( get, null ) : Bool;
	@:final 
	function get_isReleased() : Bool
	{
		return this.isReleased;
	}
}