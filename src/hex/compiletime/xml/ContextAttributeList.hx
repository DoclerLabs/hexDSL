package hex.compiletime.xml;

import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class ContextAttributeList
{
	static public inline var ID 					: String = "id";
	static public inline var TYPE 					: String = "type";
	static public inline var NAME 					: String = "name";
	static public inline var REF 					: String = "ref";
	static public inline var VALUE 					: String = "value";
	static public inline var FACTORY_METHOD 		: String = "factory-method";
	public static inline var STATIC_REF 			: String = "static-ref";
	static public inline var STATIC_CALL 			: String = "static-call";
	static public inline var INJECTOR_CREATION 		: String = "injector-creation";
	static public inline var INJECT_INTO 			: String = "inject-into";
	static public inline var METHOD 				: String = "method";
	static public inline var PARSER_CLASS 			: String = "parser-class";
	public static inline var MAP_TYPE 				: String = "map-type";
	public static inline var MAP_NAME 				: String = "map-name";
	public static inline var AS_SINGLETON 			: String = "as-singleton";
	public static inline var IF 					: String = "if";
	public static inline var IF_NOT 				: String = "if-not";
	
	/** @private */
	function new() 
	{
		throw new PrivateConstructorException();
	}
}