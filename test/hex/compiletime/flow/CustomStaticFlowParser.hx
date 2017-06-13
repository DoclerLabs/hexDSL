package hex.compiletime.flow;

import hex.compiletime.flow.BasicStaticFlowCompiler;

/**
 * ...
 * @author Francis Bourre
 */
class CustomStaticFlowParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	macro public static function prepareCompiler() : haxe.macro.Expr.ExprOf<Bool>
	{
		FlowExpressionParser.parser.methodParser.set( 'add', hex.compiletime.flow.parser.custom.AddParser.parse );
		return macro true;
	}
}