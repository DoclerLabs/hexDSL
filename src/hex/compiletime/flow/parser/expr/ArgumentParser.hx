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

class ArgumentParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	static var logger = hex.log.LogManager.LogManager.getLoggerByClass( ArgumentParser );
	
	static public function parse( parser : ExpressionParser, ident : ID, value : Expr ) : ConstructorVO
	{
		var constructorVO : ConstructorVO;

		switch( value.expr )
		{
			case EConst(CString(v)):
				constructorVO = new ConstructorVO( ident, ContextTypeList.STRING, [ v ] );

			case EConst(CInt(v)):
				constructorVO = new ConstructorVO( ident, ContextTypeList.INT, [ v ] );

			case EConst(CFloat(v)):
				constructorVO = new ConstructorVO( ident, ContextTypeList.FLOAT, [ v ] );

			case EConst(CIdent(v)):
				
				switch( v )
				{
					case "null":
						//null
						constructorVO =  new ConstructorVO( ident, ContextTypeList.NULL, [ 'null' ] );

					case "true" | "false":
						//Boolean
						constructorVO =  new ConstructorVO( ident, ContextTypeList.BOOLEAN, [ v ] );

					case _:
						//Object reference
						constructorVO =  new ConstructorVO( ident, ContextTypeList.INSTANCE, [ v ], null, null, null, v );
				}
				
			case EField( value, field ):
				//Property or method reference
				constructorVO =  new ConstructorVO( ident, ContextTypeList.INSTANCE, [], null, null, null, ExpressionUtil.compressField( value ) + '.' + field );
			
			case ENew( t, params ):
				constructorVO = parser.parseType( parser, new ConstructorVO( ident ), value );
				constructorVO.type = ExprTools.toString( value ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
				
			case EArrayDecl( values ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.ARRAY, [] );
				var it = values.iterator();
				while ( it.hasNext() ) constructorVO.arguments.push( parser.parseArgument( parser, ident, it.next() ) );
			
			case ECall( _.expr => EConst(CIdent('mapping')), params ):
				constructorVO = hex.compiletime.flow.parser.custom.MappingParser.parse( parser, new ConstructorVO( ident ), params, value );

			case EObjectDecl( fields ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.CONTEXT_ARGUMENT, [] );
				constructorVO.arguments = fields.map( function( e ) return parser.parseProperty( parser, constructorVO.ID, e.field, e.expr ) );

			case ECall( _.expr => EField( e, field ), params ):
				
				constructorVO = new ConstructorVO( ident );
				constructorVO.shouldAssign = false;
				
				switch( e.expr )
				{
					case EField( ee, ff ):
						constructorVO.arguments = [];
						if ( field != 'bind' )
						{
							constructorVO.type = ExpressionUtil.compressField( e );
							constructorVO.staticCall = field;
						}
						else
						{
							constructorVO.type = ContextTypeList.CLOSURE;
							constructorVO.ref = ExpressionUtil.compressField( e );
						}
						
					case ECall( ee, pp ):
						var call = ExpressionUtil.compressField( ee );
						var a = call.split( '.' );
						var staticCall = a.pop();
						var factory = field;
						var type = a.join( '.' );
						
						constructorVO.type = type;
						constructorVO.arguments = [];
						constructorVO.factory = factory;
						constructorVO.staticCall = staticCall;

					case EConst( ee ):
						var comp = ExpressionUtil.compressField( value );
						try
						{
							Context.getType( comp );
							constructorVO.type = comp;
							constructorVO.arguments = [];
							constructorVO.staticCall = field;
							
							trace( constructorVO );
						}
						catch ( e: Dynamic )
						{
							constructorVO.ref = comp.split('.')[0];
							constructorVO.arguments = [];
							constructorVO.instanceCall = field;
							constructorVO.type = ContextTypeList.INSTANCE;
						}

					case _:
						logger.error( e.expr );
				}
				
				if ( params.length > 0 )
				{
					constructorVO.arguments = params.map( function (e) return parser.parseArgument( parser, constructorVO.ID, e ) );
				}
			
			case _:
				logger.error( value.expr );
				Context.error( '', Context.currentPos() );
		}

		constructorVO.filePosition = value.pos;
		return constructorVO;
	}
}
#end