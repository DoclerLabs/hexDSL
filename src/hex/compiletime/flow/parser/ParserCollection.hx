package hex.compiletime.flow.parser;

#if macro
import hex.core.VariableExpression;

/**
 * ...
 * @author Francis Bourre
 */
class ParserCollection extends hex.parser.AbstractParserCollection<AbstractExprParser<hex.compiletime.basic.BuildRequest>>
{
	var _assemblerExpression : VariableExpression;
	
	public function new( assemblerExpression : VariableExpression ) 
	{
		this._assemblerExpression = assemblerExpression;
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new ApplicationContextParser( this._assemblerExpression ) );
		this._parserCollection.push( new ObjectParser() );
		this._parserCollection.push( new Launcher( this._assemblerExpression ) );
	}
}
#end