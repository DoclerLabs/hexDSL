package hex.compiletime.flow.parser.custom;

/**
 * ...
 * @author Francis Bourre
 */
#if macro
import haxe.macro.*;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;

class ArrayParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( MapParser );
	
	public static function parse( parser : ExpressionParser, constructorVO : ConstructorVO, params : Array<Expr>, expr : Expr ) : ConstructorVO
	{
		constructorVO.arguments = params.map( function(e) return parser.parseArgument( parser, constructorVO.ID, e ) );
		constructorVO.type = constructorVO.type = ExprTools.toString( expr ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
		constructorVO.filePosition = expr.pos;
		return constructorVO;
	}
}
#end