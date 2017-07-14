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
class MappingParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( MappingParser );
	
	public static function parse( parser : ExpressionParser, constructorVO : ConstructorVO, params : Array<Expr>, expr : Expr ) : ConstructorVO
	{
		switch( params[ 0 ].expr )
		{
			case EObjectDecl( fields ):
				constructorVO.type = ContextTypeList.MAPPING_DEFINITION;
				constructorVO.arguments = fields.map( function( e ) return parser.parseProperty( parser, constructorVO.ID, e.field, e.expr ) );
				constructorVO.filePosition = params[0].pos;
			
			case wtf:
				logger.error( wtf );
				haxe.macro.Context.error( '', haxe.macro.Context.currentPos() );
		}
		
		constructorVO.filePosition = expr.pos;
		return constructorVO;
	}
}
#end