package hex.compiletime.flow.parser.custom;

#if macro
import haxe.macro.*;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.compiletime.flow.parser.ExpressionUtil;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class XmlParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( XmlParser );
	
	public static function parse( parser : ExpressionParser, constructorVO : ConstructorVO, params : Array<Expr>, originalExpression : Expr ) : ConstructorVO
	{
		constructorVO.type = ContextTypeList.XML;
		
		switch( params[ 0 ].expr )
		{
			case EConst(CString(xml)):
				constructorVO.arguments = [xml];

				if ( params.length == 2 )
				{
					switch( params[ 1 ].expr )
					{
						case EField( ee, ff ):
							constructorVO.factory = ExpressionUtil.compressField( params[ 1 ] );

						case wtf:
							logger.error( wtf );
							haxe.macro.Context.error( 'Invalid factory parameter', haxe.macro.Context.currentPos() );
					}
				}
				else if ( params.length > 2)
				{
					haxe.macro.Context.error( 'Invalid number of arguments', haxe.macro.Context.currentPos() );
				}
				
			case wtf:
				logger.error( wtf );
				Context.error( '', Context.currentPos() );
		}
		
		constructorVO.filePosition = originalExpression.pos;
		return constructorVO;
	}
}
#end