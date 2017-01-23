package hex.runtime;

import hex.core.IApplicationAssembler;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.metadata.AnnotationProvider;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssembler implements IApplicationAssembler
{
	public function new() 
	{
		
	}
	
	var _mApplicationContext 			= new Map<String, IApplicationContext>();
	var _mContextFactories 				= new Map<IApplicationContext, IBuilder<Dynamic>>();
	
	public function getFactory<T>( factoryClass: Class<IBuilder<T>>, applicationContextName : String, applicationContextClass : Class<IApplicationContext> ) : IBuilder<T>
	{
		var contextFactory : IBuilder<T> = null;
		var applicationContext = this.getApplicationContext( applicationContextName, applicationContextClass );
		
		if ( this._mContextFactories.exists( applicationContext ) )
		{
			contextFactory = cast this._mContextFactories.get( applicationContext );
		}
		else
		{
			contextFactory = cast Type.createInstance( factoryClass, [] );
			contextFactory.init( applicationContext );
			this._mContextFactories.set( applicationContext, contextFactory );
		}
		
		return contextFactory;
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
	
	public function getApplicationContext<T:IApplicationContext>( applicationContextName : String, applicationContextClass : Class<T> ) : T
	{
		var applicationContext : T = null;

		if ( this._mApplicationContext.exists( applicationContextName ) )
		{
			applicationContext = cast this._mApplicationContext.get( applicationContextName );

		} else
		{
			applicationContext = Type.createInstance( applicationContextClass, [ applicationContextName ] );
			this._mApplicationContext.set( applicationContextName, applicationContext );
		}

		return applicationContext;
	}
}