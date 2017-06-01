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
class ArrayOfDependenciesOwner implements IDependencyOwner
{
	var _injector = new Injector();
	
	public function new( mappings : Array<MappingDefinition> ) 
	{
		
	}
	
	public function getInjector() : IDependencyInjector return this._injector;
}