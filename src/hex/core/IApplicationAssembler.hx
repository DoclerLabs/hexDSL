package hex.core;

import hex.core.IBuilder;

/**
 * @author Francis Bourre
 */
interface IApplicationAssembler
{
	function getFactory<T>( factoryClass: Class<IBuilder<T>>, applicationContextName : String, applicationContextClass : Class<IApplicationContext> = null ) : IBuilder<T>;
	function buildEverything() : Void;
	function release() : Void;
	function getApplicationContext( applicationContextName : String, applicationContextClass : Class<IApplicationContext> = null ) : IApplicationContext;
}