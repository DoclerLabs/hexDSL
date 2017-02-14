package hex.compiletime.xml;

import hex.error.PrivateConstructorException;

/**
 * ...
 * @author Francis Bourre
 */
class ContextNodeNameList 
{
	static public inline var INCLUDE 		= "include";
	static public inline var PROPERTY 		= "property";
	static public inline var ARGUMENT 		= "argument";
	static public inline var METHOD_CALL 	= "method-call";
	static public inline var ITEM 			= "item";
	static public inline var KEY 			= "key";
	static public inline var VALUE 			= "value";
	
	/** @private */
	function new() 
	{
		throw new PrivateConstructorException();
	}
}