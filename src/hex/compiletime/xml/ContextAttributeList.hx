package hex.compiletime.xml;

import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class ContextAttributeList
{
	static public inline var TYPE 					: String = "type";
	static public inline var NAME 					: String = "name";
	public static inline var IF 					: String = "if";
	public static inline var IF_NOT 				: String = "if-not";
	
	function new() 
	{
		throw new PrivateConstructorException( "This class can't be instantiated." );
	}
}