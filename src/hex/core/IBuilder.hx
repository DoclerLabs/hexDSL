package hex.core;

/**
 * @author Francis Bourre
 */
interface IBuilder<RequestType> 
{
	function init( applicationContextName : String, applicationContextClass : Class<IApplicationContext> = null ) : Void;
	function build( request : RequestType ) : Void;
	function finalize() : Void;
	function dispose() : Void;
	function getApplicationContext() : IApplicationContext;
}