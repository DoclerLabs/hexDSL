package hex.parser;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractParserCollection<ParserType:AbstractParserDef> 
	implements IParserCollection<AbstractParserDef>
{
	var _index 				: Int;
	var _parserCollection 	: Array<ParserType>;

	function new()
	{
		this._index 			= -1;
		this._parserCollection 	= [];
		this._buildParserList();
	}

	function _buildParserList() : Void
	{
		throw new VirtualMethodException();
	}

	public function next() : ParserType
	{
		return this._parserCollection[ ++this._index ];
	}

	public function hasNext() : Bool
	{
		return this._parserCollection.length > this._index + 1;
	}

	public function reset() : Void
	{
		this._index = -1;
	}
}