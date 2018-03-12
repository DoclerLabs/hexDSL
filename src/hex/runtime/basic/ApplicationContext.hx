package hex.runtime.basic;

import hex.core.AbstractApplicationContext;
import hex.core.IApplicationContext;
import hex.di.IBasicInjector;
import hex.di.IDependencyInjector;
import hex.di.Injector;
import hex.domain.Domain;
import hex.event.Dispatcher;
import hex.event.IDispatcher;
import hex.event.MessageType;
import hex.log.ILogger;
import hex.log.LogManager;
import hex.module.IContextModule;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContext extends AbstractApplicationContext
{
	var _dispatcher 			: IDispatcher<{}> = new Dispatcher();
	
	override public function dispatch( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		this._dispatcher.dispatch( messageType, data );
	}

	
	@:allow( hex.runtime, hex.metadata )
	function new( applicationContextName : String )
	{
		//build contextDispatcher
		var domain = Domain.getDomain( applicationContextName );
		//this._dispatcher = ApplicationDomainDispatcher.getInstance( this ).getDomainDispatcher( domain );
		
		//build injector
		var injector : IDependencyInjector = new Injector();
		injector.mapToValue( IBasicInjector, injector );
		injector.mapToValue( IDependencyInjector, injector );
		
		var logger = LogManager.getLogger( domain.getName() );
		injector.mapToValue( ILogger, logger );
		
		//build coreFactory
		var coreFactory = new CoreFactory( injector );
		
		//register applicationContext
		injector.mapToValue( IApplicationContext, this );
		injector.mapToValue( IContextModule, this );
		coreFactory.register( applicationContextName, this );
		
		super( coreFactory, applicationContextName );
		
		coreFactory.getInjector().mapClassNameToValue( "hex.event.IDispatcher<{}>", this._dispatcher );
	}
	
	override public function getLogger() : ILogger 
	{
		return this.getInjector().getInstance( ILogger );
	}
}