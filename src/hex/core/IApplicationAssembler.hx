package hex.core;

import hex.core.IBuilder;

/**
 * @author Francis Bourre
 */
interface IApplicationAssembler
{
	function getFactory<T>( factoryClass: Class<IBuilder<T>>, applicationContext : IApplicationContext ) : IBuilder<T>;
	function buildEverything() : Void;
	function release() : Void;
	function getApplicationContext<T:IApplicationContext>( applicationContextName : String, applicationContextClass : Class<T> ) : T;
}