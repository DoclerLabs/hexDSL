package hex.compiletime.flow.parser.custom;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class AddParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	public static function parse( parser : ExpressionParser, constructorVO : ConstructorVO, params : Array<Expr>, expr : Expr ) : ConstructorVO
	{
		if ( constructorVO.arguments == null ) constructorVO.arguments = [];
		
		var f = function( e ) {switch( e.expr )
		{
			case EConst(CIdent(ident)):
				constructorVO.arguments.push( new ConstructorVO( constructorVO.ID, ContextTypeList.INSTANCE, null, null, null, null, ident ) );
				case _:
		}};
		
		var e = params.shift();
		f( e );

		for ( param in params )
		{
			f( param );
			e = { expr: EBinop(OpAdd, e, param), pos:param.pos };
		}

		constructorVO.type = 'haxe.macro.Expr';
		constructorVO.arguments.unshift( e );
		constructorVO.filePosition = expr.pos;
		return constructorVO;
	}
}
#end