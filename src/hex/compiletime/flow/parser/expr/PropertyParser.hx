package hex.compiletime.flow.parser.expr;

/**
 * ...
 * @author Francis Bourre
 */
#if macro
import haxe.macro.*;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.core.ContextTypeList;
import hex.vo.PropertyVO;

class PropertyParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( PropertyParser );
	
	static public function parse( parser : ExpressionParser, ident : ID, fieldName : FieldName, assigned : Expr ) : PropertyVO
	{
		var propertyVO 	: PropertyVO;
		var type 		: String;
		var ref 		: String;
		
		switch( assigned.expr )
		{
			case EConst(CIdent(v)):
				
				switch( v )
				{
					case "null":
						propertyVO = new PropertyVO( ident, fieldName, v, ContextTypeList.NULL );
						
					case "true" | "false":
						propertyVO = new PropertyVO( ident, fieldName, v, ContextTypeList.BOOLEAN );
						
					case _:
						propertyVO = new PropertyVO( ident, fieldName, null, ContextTypeList.INSTANCE, v );
				}
				
			case ENew( t, params ):
				
				var constructorVO = parser.parseType( parser, ident, assigned );
				//constructorVO.type = ExprTools.toString( assigned.expr ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
				propertyVO = new PropertyVO( ident, fieldName, null, type, ref, null, null, constructorVO );
				
			case EConst(CInt(v)):
				propertyVO = new PropertyVO( ident, fieldName, v, ContextTypeList.INT );
				
			case EConst(CFloat(v)):
				propertyVO = new PropertyVO( ident, fieldName, v, ContextTypeList.FLOAT );
				
			case EConst(CString(v)):
				propertyVO = new PropertyVO( ident, fieldName, v, ContextTypeList.STRING );
				
			case EField( e, ff ):
				
				var className = ExpressionUtil.compressField( e, ff );
				var exp = Context.parse( '(null: ${className})', Context.currentPos() );

				switch( exp.expr )
				{
					case EParenthesis( _.expr => ECheckType( ee, TPath(p) ) ):
						
						if ( p.sub != null )
						{
							propertyVO = new PropertyVO( ident, fieldName, null, null, null, null, className );
						}
						else
						{
							propertyVO = new PropertyVO( ident, fieldName, className, ContextTypeList.CLASS );
						}
						
					case _:
						logger.debug( exp );
				}
				
			case _:
				logger.debug( assigned.expr );
		}
			
		propertyVO.filePosition = assigned.pos;
		return propertyVO;
	}
}
#end