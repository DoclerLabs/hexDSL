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
	
	override public function parse() : Void this._getExpressions().map( this._parseExpression );

	private function _parseExpression( e : Expr ) : Void
	{
		switch ( e )
		{
			case macro $i { ident } = $value:
				this._builder.build( OBJECT( this._getConstructorVO( ident, value ) ) );
			
			case macro $i{ident}.$field = $assigned:	
				var propertyVO = this.parser.parseProperty( this.parser, ident, field, assigned );
				this._builder.build( PROPERTY( propertyVO ) );
			
			case macro $i{ident}.$field( $a{params} ):
				var args = params.map( function(param) return this.parser.parseArgument(this.parser, ident, param) );
				this._builder.build( METHOD_CALL( new MethodCallVO( ident, field, args ) ) );
			
			case macro @inject_into($a{args}) $i{ident} = $value:
				var constructorVO = this._getConstructorVO( ident, value );
				constructorVO.injectInto = true;
				this._builder.build( OBJECT( constructorVO ) );
				
			case macro @map_type($a{args}) $i{ident} = $value:
				var constructorVO = this._getConstructorVO( ident, value );
				constructorVO.mapTypes = args.map( function( e ) return switch( e.expr ) 
				{ 
					case EConst(CString( mapType )) : mapType; 
					case _: "";
				} );
				this._builder.build( OBJECT( constructorVO ) );

			case _:
				//TODO remove
				logger.error('Unknown expression');
				logger.debug(e.pos);
				logger.debug(e.expr);
		}
		//logger.debug(e);
	}

	function _getConstructorVO( ident : String, value : Expr ) : ConstructorVO 
	{
		var constructorVO : ConstructorVO;
		
		switch( value.expr )
		{
			case EConst(CString(v)):
				constructorVO = new ConstructorVO( ident, ContextTypeList.STRING, [ v ] );
			
			case EConst(CInt(v)):
				constructorVO = new ConstructorVO( ident, ContextTypeList.INT, [ v ] );
				
			case EConst(CIdent(v)):
				
				switch( v )
				{
					case "null":
						constructorVO = new ConstructorVO( ident, ContextTypeList.NULL, [ v ] );
						
					case "true" | "false":
						constructorVO = new ConstructorVO( ident, ContextTypeList.BOOLEAN, [ v ] );
						
					case _:
						var type = hex.preprocess.RuntimeParametersPreprocessor.getType( v, this._runtimeParam );
						var arg = new ConstructorVO( ident, (type==null? ContextTypeList.INSTANCE : type), null, null, null, v );
						arg.filePosition = value.pos;
						constructorVO = new ConstructorVO( ident, ContextTypeList.ALIAS, [ arg ], null, null, null, v );
				}
				
			case ENew( t, params ):
				constructorVO = this.parser.parseType( this.parser, new ConstructorVO( ident ), value );
				constructorVO.type = ExprTools.toString( value ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
				
			case EObjectDecl( fields ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.OBJECT, [] );
				fields.map( function(field) this._builder.build( 
					PROPERTY( this.parser.parseProperty( this.parser, ident, field.field, field.expr ) )
				) );
				
			case EArrayDecl( values ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.ARRAY, [] );
				values.map( function( e ) constructorVO.arguments.push( this.parser.parseArgument( this.parser, ident, e ) ) );
					
			case EField( e, field ):
				
				var className = ExpressionUtil.compressField( e, field );
				var exp = Context.parse( '(null: ${className})', e.pos );

				switch( exp.expr )
				{
					case EParenthesis( _.expr => ECheckType( ee, TPath(p) ) ):
						
						constructorVO =
						if ( p.sub != null )
						{
							new ConstructorVO( ident, ContextTypeList.STATIC_VARIABLE, [], null, null, false, null, null, className );

						}
						else
						{
							new ConstructorVO( ident, ContextTypeList.CLASS, [ className ] );
						}
						
					case _:
						logger.error( exp );
				}
				
			case ECall( _.expr => EConst(CIdent(keyword)), params ):
				return this.parser.methodParser.get( keyword )( this.parser, new ConstructorVO( ident ), params, value );
				
			case ECall( _.expr => EField( e, field ), params ):
				switch( e.expr )
				{
					case EField( ee, ff ):
						constructorVO = new ConstructorVO( ident, ExpressionUtil.compressField( e ), [], null, field );
						
					case ECall( ee, pp ):

						var call = ExpressionUtil.compressField( ee );
						var a = call.split( '.' );
						var staticCall = a.pop();
						var factory = field;
						var type = a.join( '.' );
						
						constructorVO = new ConstructorVO( ident, type, [], factory, staticCall );
						
					case _:
						logger.error( e.expr );
				}
				
				if ( params.length > 0 )
				{
					constructorVO.arguments = params.map( function (e) return this.parser.parseArgument( this.parser, ident, e ) );
				}
				
			case _:
				logger.error( value.expr );
				constructorVO = new ConstructorVO( ident );
		}
		
		constructorVO.filePosition = value.pos;
		return constructorVO;
	}
}
#end