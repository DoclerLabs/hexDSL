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
	
	static public function parse( parser : ExpressionParser, constructorVO : ConstructorVO, e : Expr ) : ConstructorVO
	{
		switch( e.expr )
		{
			case ENew( t, params ):
				
				var pack = t.pack.join( '.' );
				var type = pack == "" ? t.name : pack + '.' + t.name;
				
				if ( parser.typeParser.exists( type ) )
				{
					return parser.typeParser.get( type )( parser, constructorVO, params, e );
				}
				else
				{
					constructorVO.type = type;
					constructorVO.arguments = params.map( function (param) return parser.parseArgument (parser, constructorVO.ID, param) );
				}
				
			case wtf:
				trace( wtf );
				Context.error( '', Context.currentPos() );
		}

		return constructorVO;
	}
}
#end