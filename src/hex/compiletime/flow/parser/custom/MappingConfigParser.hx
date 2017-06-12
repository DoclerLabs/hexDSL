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

class MappingConfigParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	public static function parse( parser : ExpressionParser, constructorVO : ConstructorVO, params : Array<Expr>, expr : Expr ) : ConstructorVO
	{
		if ( params.length > 0 )
		{
			switch( params[ 0 ].expr )
			{
				case EArrayDecl( values ):
					constructorVO.type = ContextTypeList.MAPPING_CONFIG;
					constructorVO.arguments = values.map( function (e) return parser.parseMapArgument( parser, constructorVO.ID, e ) );
					
				case wtf:
					trace( wtf );
					Context.error( '', Context.currentPos() );
			}
		}
		
		constructorVO.filePosition = expr.pos;
		return constructorVO;
	}
}
#end