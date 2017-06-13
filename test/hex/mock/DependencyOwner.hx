package hex.mock;

import hex.di.IDependencyInjector;
import hex.di.Injector;
import hex.di.mapping.IDependencyOwner;
import hex.di.mapping.MappingDefinition;

/**
 * ...
 * @author Francis Bourre
 */
@Dependency( var _:String )
@Dependency( var id:Interface)
class DependencyOwner implements IDependencyOwner
{
	var _injector = new Injector();
	
	public function new( mapping1 : MappingDefinition, mapping2 : MappingDefinition ) 
	{
		
	}
	
	public function getInjector() : IDependencyInjector return this._injector;
}