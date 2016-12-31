package hex.runtime;

import hex.core.IApplicationAssembler;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.factory.BuildRequest;
import hex.ioc.core.ContextFactory;
import hex.metadata.AnnotationProvider;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssembler implements IApplicationAssembler
{
	public function new() 
	{
		this._test( BuildRequest );
	}
	
	var _mApplicationContext 			= new Map<String, IApplicationContext>();
	var _mContextFactories 				= new Map<IApplicationContext, IBuilder<Dynamic>>();
	
	public function getBuilder<T>( en : Enum<T>, applicationContext : IApplicationContext ) : IBuilder<T>
	{
		return cast this._mContextFactories.get( applicationContext );
	}
	
	function _test<T>( o : Enum<T> ) : Void
	{
		
	}
	
	public function buildEverything() : Void
	{
		var itFactory = this._mContextFactories.iterator();
		var contextFactories = [ while ( itFactory.hasNext() ) itFactory.next() ];
		contextFactories.map( function( factory ) { factory.finalize(); } );
	}

	public function release() : Void
	{
		var itFactory = this._mContextFactories.iterator();
		while ( itFactory.hasNext() ) itFactory.next().dispose();
		
		this._mApplicationContext = new Map();
		this._mContextFactories = new Map();
		AnnotationProvider.release();
	}
	
	public function getApplicationContext( applicationContextName : String, applicationContextClass : Class<IApplicationContext> = null ) : IApplicationContext
	{
		var applicationContext : IApplicationContext;

		if ( this._mApplicationContext.exists( applicationContextName ) )
		{
			applicationContext = this._mApplicationContext.get( applicationContextName );

		} else
		{
			var contextFactory = new ContextFactory();
			contextFactory.init( applicationContextName, applicationContextClass );
			applicationContext = contextFactory.getApplicationContext();
			
			this._mApplicationContext.set( applicationContextName, applicationContext);
			this._mContextFactories.set( applicationContext, contextFactory );
		}

		return applicationContext;
	}
}