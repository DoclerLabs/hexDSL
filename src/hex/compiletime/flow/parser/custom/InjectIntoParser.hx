package hex.compiletime.flow.parser.custom;

#if macro
import haxe.macro.*;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class InjectIntoParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( InjectIntoParser );
	
	public static function parse( parser : ExpressionParser, constructorVO : ConstructorVO, params : Array<Expr>, expr : Expr ) : ConstructorVO
	{
		constructorVO.injectInto = true;
		constructorVO.filePosition = expr.pos;
		return parser.parseType( parser, constructorVO, params[0] );
	}
}
#end