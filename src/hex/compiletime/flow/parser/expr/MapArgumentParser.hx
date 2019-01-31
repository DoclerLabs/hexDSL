package hex.compiletime.flow.parser.expr;

/**
 * ...
 * @author Francis Bourre
 */
#if macro
import haxe.macro.*;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.core.ContextTypeList;
import hex.vo.MapVO;

using hex.error.Error;

class MapArgumentParser 
{
	/** @private */ function new() throw new PrivateConstructorException();
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( MapArgumentParser );
	
	static public function parse( parser : ExpressionParser, ident : ID, param : Expr ) : MapVO
	{
		return	switch( param.expr )
		{
			case EBinop( OpArrow, e1, e2 ):
				
				var key 			= parser.parseArgument( parser, ident, e1 );
				var value 			= parser.parseArgument( parser, ident, e2 );
				var mapVO 			= new MapVO( key, value );
				mapVO.filePosition 	= param.pos;
				return mapVO;
				
			case wtf:
				logger.error( wtf );
				haxe.macro.Context.error( '', haxe.macro.Context.currentPos() );
				null;
		}
	}
}
#end