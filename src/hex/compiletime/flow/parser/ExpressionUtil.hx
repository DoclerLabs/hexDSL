package hex.compiletime.flow.parser;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import hex.core.ContextTypeList;
import hex.log.LogManager;
import hex.vo.ConstructorVO;
import hex.vo.MapVO;
import hex.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
@:final
class ExpressionUtil 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();

	static var logger = LogManager.getLoggerByClass(ExpressionUtil);
	
	static public function compressField( e : ExprDef, ?previousValue : String = "" ) : String
	{
		return switch( e )
		{
			case EField( ee, field ):
				previousValue = previousValue == "" ? field : field + "." + previousValue;
				return compressField( ee.expr, previousValue );
				
			case EConst( CIdent( id ) ):
				return previousValue == "" ? id : id + "." + previousValue;

			default:
				return previousValue;
		}
	}
	
	static public function getArgument( ident : String, value : Expr ) : ConstructorVO
	{
		var constructorVO : ConstructorVO;

		switch( value.expr )
		{
			case EConst(CString(v)):
				//String
				constructorVO = new ConstructorVO( ident, ContextTypeList.STRING, [ v ] );

			case EConst(CInt(v)):
				//Int
				constructorVO = new ConstructorVO( ident, ContextTypeList.INT, [ v ] );

			case EConst(CFloat(v)):
				//Float
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
				constructorVO =  new ConstructorVO( ident, ContextTypeList.INSTANCE, [], null, null, null, compressField(value.expr) + '.' + field );
			
			case ENew( t, params ):
				constructorVO = ExpressionUtil.getVOFromNewExpr( ident, t, params );
				constructorVO.type = ExprTools.toString( value ).split( 'new ' )[ 1 ].split( '(' )[ 0 ];
				
			case EArrayDecl( values ):
				constructorVO = new ConstructorVO( ident, ContextTypeList.ARRAY, [] );
				var it = values.iterator();
				while ( it.hasNext() ) constructorVO.arguments.push( ExpressionUtil.getArgument( ident, it.next() ) );
			
			case ECall( _.expr => EConst(CIdent('mapping')), params ):

				for ( param in params )
				{
					switch( param.expr )
					{
						case EObjectDecl( fields ):

							var args = [];
							var it = fields.iterator();
							while ( it.hasNext() )
							{
								var argument = it.next();
								args.push( ExpressionUtil.getProperty( ident, argument.field, argument.expr ) );
							}

							constructorVO = new ConstructorVO( ident, ContextTypeList.MAPPING_DEFINITION, args );
							constructorVO.filePosition = param.pos;
							
						case _:
							trace( 'WTF' );
					}
				}
				
				
				
			case _:
				trace( value.expr );
				logger.debug( value.expr );
		}

		constructorVO.filePosition = value.pos;
		return constructorVO;
	}
	
	static public function getVOFromNewExpr( ident : String, t : TypePath, params : Array<Expr> ) : ConstructorVO
	{
		var constructorVO : ConstructorVO;
		
		var pack = t.pack.join( '.' );
		var type = pack == "" ? t.name : pack + '.' + t.name;

		switch ( type )
		{
			case ContextTypeList.HASHMAP | 
					ContextTypeList.MAPPING_CONFIG:
				
				if ( params.length > 0 )
				{
					switch( params[ 0 ].expr )
					{
						case EArrayDecl( values ):
							constructorVO = new ConstructorVO( ident, ExpressionUtil.getFullClassDeclaration( t ), ExpressionUtil.getMapArguments( ident, values ) );
							
						case _:
							//logger.error( params[ 0 ].expr );
					}
					//
				}
			case ContextTypeList.MAPPING_DEFINITION:
				
				switch( params[0].expr )
				{
					case EObjectDecl( fields ):
						
						var args = [];
						var it = fields.iterator();
						while ( it.hasNext() )
						{
							var argument = it.next();
							args.push( ExpressionUtil.getProperty( ident, argument.field, argument.expr ) );
						}
						
						constructorVO = new ConstructorVO( ident, ContextTypeList.MAPPING_DEFINITION, args );
					case _:
						trace( 'WTF' );
				}
				
				
			case _ :
				constructorVO = new ConstructorVO( ident, type, [] );
				
				if ( params.length > 0 )
				{
					var it = params.iterator();
					while ( it.hasNext() )
						constructorVO.arguments.push( ExpressionUtil.getArgument( ident, it.next() ) );
				}
		}
		
		return constructorVO;
	}
	
	static public function getProperty( ident : String, field : String, assigned : Expr ) : PropertyVO
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
						type = ContextTypeList.NULL;
						propertyVO = new PropertyVO( ident, field, v, type, ref );
						
					case "true" | "false":
						type = ContextTypeList.BOOLEAN;
						propertyVO = new PropertyVO( ident, field, v, type, ref );
						
					case _:
						type = ContextTypeList.INSTANCE;
						ref = v;
						v = null;
						propertyVO = new PropertyVO( ident, field, v, type, ref );
				}
			
			case EConst(CInt(v)):
				//Int
				propertyVO = new PropertyVO( ident, field, v, ContextTypeList.INT );
				
			case EConst(CFloat(v)):
				//Float
				propertyVO = new PropertyVO( ident, field, v, ContextTypeList.FLOAT );
				
			case EConst(CString(v)):
				//String
				propertyVO = new PropertyVO( ident, field, v, ContextTypeList.STRING );
				
			case EField( e, ff ):
				
				var className = ExpressionUtil.compressField( e.expr, ff );
				var exp = Context.parse( '(null: ${className})', Context.currentPos() );

				switch( exp.expr )
				{
					case EParenthesis( _.expr => ECheckType( ee, TPath(p) ) ):
						
						if ( p.sub != null )
						{
							propertyVO = new PropertyVO( ident, field, null, null, null, null, className );
						}
						else
						{
							propertyVO = new PropertyVO( ident, field, className, ContextTypeList.CLASS, null, null, null );
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
	
	static public function getMapArguments( ident : String, params : Array<Expr> ) : Array<MapVO>
	{
		var args : Array<MapVO> = [];
		
		var it = params.iterator();
		while ( it.hasNext() )
		{
			var param = it.next();
			
			switch( param.expr )
			{
				case EBinop( OpArrow, e1, e2 ):
					
					var key 	= ExpressionUtil.getArgument( ident, e1 );
					var value 	= ExpressionUtil.getArgument( ident, e2 );
					var mapVO 	= new MapVO( key, value );
					mapVO.filePosition = param.pos;
					args.push( mapVO );
					
				case _:
					
					logger.debug( param.expr );
			}
		}
		
		return args;
	}
	
	static public function getFullClassDeclaration( tp : TypePath ) : String
	{
		var className = ExprTools.toString( macro new $tp() );
		return className.split( "new " ).join( '' ).split( '()' ).join( '' );
	}
}
#end