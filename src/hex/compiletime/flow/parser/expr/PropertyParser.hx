package hex.compiletime.flow.parser.expr;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import hex.compiletime.flow.parser.ExpressionParser;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;
import hex.vo.PropertyVO;

using tink.MacroApi;
/**
 * ...
 * @author Francis Bourre
 */
class PropertyParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( PropertyParser );
	
	static public function parse( parser : ExpressionParser, ident : ID, fieldName : FieldName, value : Expr ) : PropertyVO
	{
		var propertyVO 	: PropertyVO;
		var type 		: String;
		var ref 		: String;

		switch( value.expr )
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
				
				var constructorVO = parser.parseType( parser, new ConstructorVO( ident ), value );
				propertyVO = new PropertyVO( ident, fieldName, null, type, ref, null, null, constructorVO );
				
			case EConst(CInt(v)):
				propertyVO = new PropertyVO( ident, fieldName, v, ContextTypeList.INT );
				
			case EConst(CFloat(v)):
				propertyVO = new PropertyVO( ident, fieldName, v, ContextTypeList.FLOAT );
				
			case EConst(CString(v)):
				propertyVO = new PropertyVO( ident, fieldName, v, ContextTypeList.STRING );

			case EArrayDecl( values ):
				
				var isMap = function ( v ) return switch( v[ 0 ].expr ) { case EBinop( op, e1, e2 ): op == OpArrow;  case _: false; };
				var constructorVO = new ConstructorVO( ident );

				if ( values.length > 0 && isMap( values ) )
				{
					constructorVO.type = ContextTypeList.EXPRESSION;
					constructorVO.arguments = [ value ];
					constructorVO.arguments = constructorVO.arguments.concat( values.map( function (e) return parser.parseMapArgument( parser, constructorVO.ID, e ) ) );
					propertyVO = new PropertyVO( ident, fieldName, null, ContextTypeList.MAP, constructorVO );
				}
				else
				{
					constructorVO.type = ContextTypeList.ARRAY;
					constructorVO.arguments = [];
					values.map( function( e ) constructorVO.arguments.push( parser.parseArgument( parser, constructorVO.ID, e ) ) );

					propertyVO = new PropertyVO( ident, fieldName, null, ContextTypeList.ARRAY, constructorVO );
				}

			case EObjectDecl( fields ):

				propertyVO = new PropertyVO( ident, fieldName, null, ContextTypeList.CONTEXT_ARGUMENT,
					parser.parseArgument( parser, ident, value )
				);
				
			case EField( e, ff ):
				
				try
				{
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
				}
				catch ( err : Dynamic )
				{
					propertyVO = new PropertyVO( ident, fieldName, null, null, ExpressionUtil.compressField( e, ff ) );
				}
				
			case ECall( _.expr => EConst(CIdent(keyword)), params ):

				var constructorVO = new ConstructorVO( ident );
				constructorVO.ref = ExpressionUtil.compressField( value );
				constructorVO.arguments = params.map( function (e) return parser.parseArgument( parser, constructorVO.ID, e ) );
				constructorVO.instanceCall = constructorVO.ref;
				constructorVO.type = ContextTypeList.CLOSURE_FACTORY;
				constructorVO.shouldAssign = false;
				propertyVO = new PropertyVO( ident, fieldName, null, type, ref, null, null, constructorVO );

				
			case ECall( _.expr => EField( e, field ), params ):
				
				var constructorVO = new ConstructorVO( ident );
				constructorVO.shouldAssign = false;
				
				switch( e.expr )
				{
					case EField( ee, ff ):
						constructorVO.arguments = [];
						if ( field != 'bind' )
						{
							constructorVO.type = ContextTypeList.EXPRESSION;
							constructorVO.arguments = [ value ];
						}
						else
						{
							constructorVO.type = ContextTypeList.CLOSURE;
							constructorVO.ref = ExpressionUtil.compressField( e );
						}
						
					case ECall( ee, pp ):
						
						constructorVO.type = ContextTypeList.EXPRESSION;
						constructorVO.arguments = [ value ];
						constructorVO.arguments = constructorVO.arguments.concat( pp.map( function (e) return parser.parseArgument( parser, constructorVO.ID, e ) ) );
					
					case EConst( ee ):
						
						var comp = ExpressionUtil.compressField( e );
						
						constructorVO.type = ContextTypeList.EXPRESSION;
						constructorVO.arguments = [ value ];
						
						try
						{
							Context.getType( comp );
						}
						catch ( e: Dynamic )
						{
							constructorVO.ref = comp.split('.')[0];
						}

					case _:
						logger.error( e.expr );
				}
				
				if ( params.length > 0 )
				{
					constructorVO.arguments = constructorVO.arguments.concat( params.map( function (e) return parser.parseArgument( parser, constructorVO.ID, e ) ) );
				}

				propertyVO = new PropertyVO( ident, fieldName, null, type, ref, null, null, constructorVO );

			case _:
				value.reject('This type of expression cannot be used here: ${value.toString()}');
		}

		propertyVO.filePosition = value.pos;
		return propertyVO;
	}
}
#end
