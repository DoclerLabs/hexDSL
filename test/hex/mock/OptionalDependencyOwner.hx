package hex.mock;

import hex.di.IDependencyInjector;
import hex.di.Injector;
import hex.di.mapping.IDependencyOwner;
import hex.di.mapping.MappingDefinition;

/**
 * ...
 * @author Francis Bourre
 */
@Dependency( var _:String->String )
class OptionalDependencyOwner implements IDependencyOwner
{
	var _injector = new Injector();
	
	public function new( mapping : MappingDefinition ) 
	{
		
	}
	
	public function getInjector() : IDependencyInjector return this._injector;
	
	public static function string( ?s : String ) : Int return Std.parseInt(s);
}