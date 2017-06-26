package hex.core;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextUtil 
{
	static var variableNameEreg = ~/[a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*/;

	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function isValidName( name : String ) : Bool
	{
		if( variableNameEreg.match( name ) )
		{
			return variableNameEreg.matched(0) == name;
		}
		return false;
		//Context.error( 'Invalid application context name.\n Name should be alphanumeric (underscore is allowed).\n First chararcter should not be a number.', Context.currentPos() );
	}
}