package hex.compiletime.flow.parser;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import hex.compiletime.flow.AbstractExprParser;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;
import hex.vo.MethodCallVO;
import hex.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
class ObjectParser extends AbstractExprParser<hex.compiletime.basic.BuildRequest>
{
	var logger 				: hex.log.ILogger;
	var parser 				: ExpressionParser;
	var _runtimeParam 		: hex.preprocess.RuntimeParam;

	public function new( parser : ExpressionParser, ?runtimeParam : hex.preprocess.RuntimeParam ) 
	{
		super();
		
		this.logger 		= hex.log.LogManager.getLoggerByInstance( this );
		this.parser 		= parser;
		this._runtimeParam 	= runtimeParam;
	}
	
	override public function parse() : Void this._getExpressions().map( this._parse );
	private function _parse( e : Expr ) this._parseExpression( e, new ConstructorVO( '' ) );

	private function _parseExpression( e : Expr, constructorVO : ConstructorVO ) : Void
	{
		switch ( e )
		{
			case macro $i { ident } = $value:
				constructorVO.ID = ident;
				this._builder.build( OBJECT( this._getConstructorVO( constructorVO, value ) ) );
			
			case macro $i{ident}.$field = $assigned:	
				var propertyVO = this.parser.parseProperty( this.parser, ident, field, assigned );
				this._builder.build( PROPERTY( propertyVO ) );
			
			case macro $i{ident}.$field( $a{params} ):
				var args = params.map( function(param) return this.parser.parseArgument(this.parser, ident, param) );
				this._builder.build( METHOD_CALL( new MethodCallVO( ident, field, args ) ) );
			
			case macro @inject_into($a { args } ) $e:
				constructorVO.injectInto = true;
				this._parseExpression ( e, constructorVO );
				
			case macro @map_type( $a{ args } ) $e:
				constructorVO.mapTypes = args.map( function( e ) return switch( e.expr ) 
				{ 
					case EConst(CString( mapType )) : mapType; 
					case _: "";
				} );
				this._parseExpression ( e, constructorVO );
				
			case macro @type( $a{ args } ) $e:
				constructorVO.abstractType = switch( args[ 0 ].expr ) 
				{ 
					case EConst(CString( abstractType )) : abstractType; 
					case _: "";
				}
				this._parseExpression ( e, constructorVO );
				
			case _:
				
				switch( e.expr )
				{
					case EMeta( meta, e ):
						trace( e );
				
					//TODO refactor - Should be part of the property parser
					case EBinop( OpAssign, _.expr => EField( ref, field ), value ):
						var fields = ExpressionUtil.compressField( ref, field ).split('.');
						var ident = fields.shift();
						var fieldName = fields.join('.');
						this._builder.build( PROPERTY( this.parser.parseProperty( this.parser, ident, fieldName, value ) ) );
					
					//TODO refactor - Should be part of the method parser	
					case ECall( _.expr => EField( ref, field ), params ):
						var ident = ExpressionUtil.compressField( ref );
						var args = params.map( function( param ) return this.parser.parseArgument( this.parser, ident, param ) );
						this._builder.build( METHOD_CALL( new MethodCallVO( ident, field, args ) ) );
						
					case _:
						//TODO remove
						logger.error( 'Unknown expression' );
						logger.debug( e.pos );
						logger.debug( e.expr );
				}
				
		}
		//logger.debug(e);
	}

	function _getConstructorVO( constructorVO : ConstructorVO, value : Expr ) : ConstructorVO 
	{
		switch( value.expr )
		{
			case EConst(CString(v)):
				constructorVO.type = ContextTypeList.STRING;
				constructorVO.arguments = [ v ];
			
			case EConst(CInt(v)):
				constructorVO.type = ContextTypeList.INT;
				constructorVO.arguments = [ v ];
				
			case EConst(CFloat(v)):
				constructorVO.type = ContextTypeList.FLOAT;
				constructorVO.arguments = [ v ];
				
			case EConst(CIdent(v)):
				
				switch( v )
				{
					case "null":
						constructorVO.type = ContextTypeList.NULL;
						constructorVO.arguments = [ v ];
						
					case "true" | "false":
						constructorVO.type = ContextTypeList.BOOLEAN;
						constructorVO.arguments = [ v ];
						
					case _:
						var type = hex.preprocess.RuntimeParametersPreprocessor.getType( v, this._runtimeParam );
						var arg = new ConstructorVO( constructorVO.ID, (type==null? ContextTypeList.INSTANCE : type), null, null, null, v );
						arg.filePosition = value.pos;
						
						constructorVO.type = ContextTypeList.ALIAS;
						constructorVO.arguments = [ arg ];
						constructorVO.ref = v;
				}
				
			case ENew( t, params ):
				this.parser.parseType( this.parser, constructorVO, value );
				constructorVO.type = ExprTools.toString( value ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
				
			case EObjectDecl( fields ):
				constructorVO.type = ContextTypeList.OBJECT;
				constructorVO.arguments = [];
				fields.map( function(field) this._builder.build( 
					PROPERTY( this.parser.parseProperty( this.parser, constructorVO.ID, field.field, field.expr ) )
				) );
				
			case EArrayDecl( values ):
				constructorVO.type = ContextTypeList.ARRAY;
				constructorVO.arguments = [];
				values.map( function( e ) constructorVO.arguments.push( this.parser.parseArgument( this.parser, constructorVO.ID, e ) ) );
					
			case EField( e, field ):
				
				var className = ExpressionUtil.compressField( e, field );

				try
				{
					//
					var exp = Context.parse( '(null: ${className})', e.pos );

					switch( exp.expr )
					{
						case EParenthesis( _.expr => ECheckType( ee, TPath(p) ) ):
							
							//constructorVO =
							if ( p.sub != null )
							{
								constructorVO.type = ContextTypeList.STATIC_VARIABLE;
								constructorVO.arguments = [];
								constructorVO.staticRef = className;
							}
							else
							{
								constructorVO.type = ContextTypeList.CLASS;
								constructorVO.arguments = [ className];
							}
							
						case _:
							logger.error( exp );
					}
				}
				catch ( e : Dynamic )
				{
					//TODO refactor
					var type = hex.preprocess.RuntimeParametersPreprocessor.getType( className, this._runtimeParam );
					var arg = new ConstructorVO( constructorVO.ID, (type==null? ContextTypeList.INSTANCE : type), null, null, null, className );
					arg.filePosition = e.pos;
					
					constructorVO.type = ContextTypeList.ALIAS;
					constructorVO.arguments = [ arg ];
					constructorVO.ref = className;
				}
				
			case ECall( _.expr => EConst(CIdent(keyword)), params ):
				if ( this.parser.buildMethodParser.exists( keyword ) )
				{
					return this.parser.buildMethodParser.get( keyword )( this.parser, constructorVO, params, value );
				}
				else
				{
					Context.error( "'" + keyword + "' keyword is not defined for your current compiler", value.pos );
				}
				
				
			case ECall( _.expr => EField( e, field ), params ):
				switch( e.expr )
				{
					case EField( ee, ff ):
						constructorVO.type = ExpressionUtil.compressField( e );
						constructorVO.arguments = [];
						constructorVO.staticCall = field;
						
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
						
					case _:
						logger.error( e.expr );
				}
				
				if ( params.length > 0 )
				{
					constructorVO.arguments = params.map( function (e) return this.parser.parseArgument( this.parser, constructorVO.ID, e ) );
				}
				
			case _:
				logger.error( value.expr );
		}
		
		constructorVO.filePosition = value.pos;
		return constructorVO;
	}
}
#end