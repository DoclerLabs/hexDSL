package hex.compiletime.flow;

/**
 * ...
 * @author Francis Bourre
 */
@:final 
class ContextKeywordList 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();

	static public inline var CONTEXT 	: String = "context";
	static public inline var TYPE 		: String = "type";
	static public inline var NAME 		: String = "name";
	static public inline var PARAMS 	: String = "params";
}