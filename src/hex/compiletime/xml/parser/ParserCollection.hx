package hex.compiletime.xml.parser;

#if macro
import hex.compiletime.xml.AbstractXmlParser;
import hex.parser.AbstractParserCollection;

/**
 * ...
 * @author Francis Bourre
 */
class ParserCollection extends AbstractParserCollection<AbstractXmlParser<hex.compiletime.basic.BuildRequest>>
{
	public function new() 
	{
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new ApplicationContextParser() );
		this._parserCollection.push( new ObjectParser() );
		this._parserCollection.push( new Launcher() );
	}
}
#end