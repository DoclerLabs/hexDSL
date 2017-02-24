package hex.mock;

import hex.config.stateful.IStatefulConfig;
import hex.di.Dependency;
import hex.event.ITrigger;
import hex.module.Module;

/**
 * ...
 * @author Francis Bourre
 */
class MockModuleListener extends Module
{
	public function new( config : IStatefulConfig ) 
	{
		super();
		
		this._addStatefulConfigs( [config] );
		//this._get( ITrigger, 'temperature' ).connect( this.setTemperature );
		//this._get( ITrigger, 'weather' ).connect( this.setWeather );
		
		//this._test();
		this._getDependency( new Dependency<ITrigger<String->Void>>(), 'weather' ).dowhatever( this.setTemperature );
		//this._getDependency( new Dependency<ITrigger<Int->Void>>, 'weather'  ).connect( this.setTemperature );
		
		//this._injector.getInstanceWithClassName( 'ITrigger<String->Void>' )
	}
	
	public function setTemperature( s : String ) : Void
	{
		
	}
	
	public function setWeather( i : Int ) : Void
	{
		
	}
	
}