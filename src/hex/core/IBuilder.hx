package hex.core;

/**
 * @author Francis Bourre
 */
interface IBuilder<RequestType> 
{
	function init( applicationContext : IApplicationContext ) : Void;
	function build( request : RequestType ) : Void;
	function finalize() : Void;
	function dispose() : Void;
	function getApplicationContext() : IApplicationContext;
}