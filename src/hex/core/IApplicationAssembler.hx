package hex.core;

import hex.core.IBuilder;

/**
 * @author Francis Bourre
 */
interface IApplicationAssembler
{
	function getBuilder<T>( applicationContext : IApplicationContext ) : IBuilder<T>;
	function buildEverything() : Void;
	function release() : Void;
	function getApplicationContext( applicationContextName : String, applicationContextClass : Class<IApplicationContext> = null ) : IApplicationContext;
}