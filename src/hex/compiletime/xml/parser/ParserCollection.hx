package hex.compiletime.xml.parser;

#if macro
import hex.core.VariableExpression;

/**
 * ...
 * @author Francis Bourre
 */
class ParserCollection extends hex.parser.AbstractParserCollection<hex.compiletime.xml.AbstractXmlParser<hex.compiletime.basic.BuildRequest>>
{
	var _assemblerVariable : VariableExpression;
	
	public function new( assemblerVar : VariableExpression ) 
	{
		this._assemblerVariable = assemblerVar;
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new ApplicationContextParser( this._assemblerVariable ) );
		this._parserCollection.push( new ObjectParser() );
		this._parserCollection.push( new Launcher( this._assemblerVariable ) );
	}
}
#end