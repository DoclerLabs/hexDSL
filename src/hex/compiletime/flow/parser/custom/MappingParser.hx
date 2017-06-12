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
	
	public static function parse( parser : ExpressionParser, id : ID, params : Array<Expr>, expr : Expr ) : ConstructorVO
	{
		var constructorVO : ConstructorVO;
		
		switch( params[ 0 ].expr )
		{
			case EObjectDecl( fields ):
				
				var args = fields.map( function( e ) return parser.parseProperty( parser, id, e.field, e.expr ) );
				constructorVO = new ConstructorVO( id, ContextTypeList.MAPPING_DEFINITION, args );
				constructorVO.filePosition = params[0].pos;
			
			case wtf:
				trace( wtf );
				haxe.macro.Context.error( '', haxe.macro.Context.currentPos() );
		}
		
		constructorVO.filePosition = expr.pos;
		return constructorVO;
	}
}
#end