package hex.parser;

/**
 * @author Francis Bourre
 */
interface IParserCollection<T:AbstractParserDef>
{
	function next() : T;
	
	function hasNext() : Bool;
		
	function reset() : Void;
}