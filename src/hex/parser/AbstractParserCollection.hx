package hex.parser;

import hex.error.VirtualMethodException;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractParserCollection<T:AbstractContextParser<ContentType>, ContentType> 
	implements IParserCollection<AbstractContextParser<ContentType>, ContentType>
{
	var _index 						: Int;
	var _parserCommandCollection 	: Array<T>;

	function new()
	{
		this._index = -1;
		this._parserCommandCollection = [];
		this._buildParserList();
	}

	function _buildParserList() : Void
	{
		throw new VirtualMethodException( this + ".setParserList() must be implemented in concrete class." );
	}

	public function next() : T
	{
		return _parserCommandCollection[ ++this._index ];
	}

	public function hasNext() : Bool
	{
		return _parserCommandCollection.length > this._index + 1;
	}

	public function reset() : Void
	{
		this._index = -1;
	}
}