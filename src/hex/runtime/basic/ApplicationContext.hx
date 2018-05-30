package hex.runtime.basic;

import hex.core.AbstractApplicationContext;
import hex.core.IApplicationContext;
import hex.di.IBasicInjector;
import hex.di.IDependencyInjector;
import hex.di.Injector;
import hex.log.ILogger;
import hex.log.LogManager;
import hex.module.IContextModule;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContext extends AbstractApplicationContext
{
	@:allow( hex.runtime, hex.metadata )
	@:keep
	function new( applicationContextName : String )
	{
		//build injector
		var injector : IDependencyInjector = new Injector();
		injector.mapToValue( IBasicInjector, injector );
		injector.mapToValue( IDependencyInjector, injector );
		
		var logger = LogManager.getLogger( applicationContextName );
		injector.mapToValue( ILogger, logger );
		
		//build coreFactory
		var coreFactory = new CoreFactory( injector );
		
		//register applicationContext
		injector.mapToValue( IApplicationContext, this );
		injector.mapToValue( IContextModule, this );
		coreFactory.register( applicationContextName, this );
		
		super( coreFactory, applicationContextName );
	}
	
	override public function getLogger() return this.getInjector().getInstance( ILogger );
}