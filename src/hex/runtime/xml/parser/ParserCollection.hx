package hex.runtime.xml.parser;

import hex.parser.AbstractParserCollection;
import hex.runtime.xml.AbstractXMLParser;

/**
 * ...
 * @author Francis Bourre
 */
class ParserCollection extends AbstractParserCollection<AbstractXMLParser<hex.compiletime.basic.BuildRequest>>
{
	private var _isAutoBuild : Bool = false;
	
	public function new( isAutoBuild : Bool = false ) 
	{
		this._isAutoBuild = isAutoBuild;
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new ObjectParser() );

		if ( this._isAutoBuild )
		{
			this._parserCollection.push( new AutoBuildLauncher() );
		}
	}
}