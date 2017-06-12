package hex.compiletime.flow.parser.expr;

/**
 * ...
 * @author Francis Bourre
 */
#if macro
import haxe.macro.*;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;

class TypeParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function parse( parser : ExpressionParser, ident : String, e : Expr ) : ConstructorVO
	{
		var constructorVO : ConstructorVO = null;
		
		switch( e.expr )
		{
			case ENew( t, params ):
				
				var pack = t.pack.join( '.' );
				var type = pack == "" ? t.name : pack + '.' + t.name;
				
				if ( parser.typeParser.exists( type ) )
				{
					return parser.typeParser.get( type )( parser, ident, params, e );
				}
				else
				{
					constructorVO = new ConstructorVO( ident, type, [] );
					constructorVO.arguments = params.map( function (param) return parser.parseArgument (parser, ident, param) );
				}
				
			case wtf:
		}

		return constructorVO;
	}
}
#end