package hex.core;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextUtil 
{
	static var variableNameEreg = ~/[a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*/;

	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function isValidName( name : String ) : Bool
	{
		if( variableNameEreg.match( name ) )
		{
			return variableNameEreg.matched( 0 ) == name;
		}
		
		return false;
	}
}