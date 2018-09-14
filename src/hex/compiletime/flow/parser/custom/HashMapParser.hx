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

class HashMapParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( HashMapParser );
	
	public static function parse( parser : ExpressionParser, constructorVO : ConstructorVO, params : Array<Expr>, expr : Expr ) : ConstructorVO
	{
		if ( params.length > 0 )
		{
			switch( params[ 0 ].expr )
			{
				case EArrayDecl( values ):
					constructorVO.type = ContextTypeList.HASHMAP;
					constructorVO.fqcn = ExprTools.toString( expr ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
					constructorVO.arguments = values.map( function(e) return parser.parseMapArgument( parser, constructorVO.ID, e ) );
					
				case wtf:
					logger.error( wtf );
					haxe.macro.Context.error( 'HashMapParser fails', constructorVO.filePosition );
			}
		}
		
		constructorVO.filePosition = expr.pos;
		return constructorVO;
	}
}
#end