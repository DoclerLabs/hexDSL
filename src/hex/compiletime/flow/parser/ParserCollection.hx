package hex.compiletime.flow.parser;

#if macro
import hex.core.VariableExpression;
import hex.compiletime.flow.BasicStaticFlowCompiler;

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
		this._parserCollection.push( new hex.compiletime.flow.parser.ApplicationContextParser( this._assemblerExpression ) );
		this._parserCollection.push( new hex.compiletime.flow.parser.ObjectParser( hex.compiletime.flow.parser.FlowExpressionParser.parser ) );
		this._parserCollection.push( new hex.compiletime.flow.parser.Launcher( this._assemblerExpression ) );
	}
}
#end