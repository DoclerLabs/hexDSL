package hex.core;

/**
 * @author Francis Bourre
 */
interface IBuilder<RequestType> 
{
	function build( request : RequestType ) : Void;
}