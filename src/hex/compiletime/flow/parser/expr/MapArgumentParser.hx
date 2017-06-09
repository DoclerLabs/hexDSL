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

class MapArgumentParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
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
				trace( wtf );
				haxe.macro.Context.error( '', haxe.macro.Context.currentPos() );
				null;
		}
	}
}
#end