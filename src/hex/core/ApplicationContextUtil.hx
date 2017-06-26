package hex.core;

#if macro
import haxe.macro.*;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextUtil 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function validateName( name : String )
	{
		//Context.error( 'Invalid application context name.\n Name should be alphanumeric (underscore is allowed).\n First chararcter should not be a number.', Context.currentPos() );
	}
}
#end