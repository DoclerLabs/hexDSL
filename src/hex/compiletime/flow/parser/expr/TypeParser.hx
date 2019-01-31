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

using hex.error.Error;

class TypeParser 
{
	/** @private */ function new() throw new PrivateConstructorException();
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( TypeParser );
	
	static public function parse( parser : ExpressionParser, constructorVO : ConstructorVO, e : Expr ) : ConstructorVO
	{
		var fqcn = ExprTools.toString( e ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
		
		switch( e.expr )
		{
			case ENew( t, params ):
				
				var pack = t.pack.join( '.' );
				var type = pack == "" ? t.name : pack + '.' + t.name;
				
				if ( parser.typeParser.exists( type ) )
				{
					constructorVO.type = fqcn;
					return parser.typeParser.get( type )( parser, constructorVO, params, e );
				}
				else
				{
					//constructorVO.type = type;
					constructorVO.type = ContextTypeList.EXPRESSION;
					constructorVO.arguments = params.map( function (param) return parser.parseArgument (parser, constructorVO.ID, param) );
					constructorVO.arguments.unshift( e );
				}

				constructorVO.fqcn = fqcn;
				
			case wtf:
				logger.error( wtf );
				Context.error( '', Context.currentPos() );
		}

		return constructorVO;
	}
}
#end