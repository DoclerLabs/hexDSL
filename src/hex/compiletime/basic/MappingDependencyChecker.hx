package hex.compiletime.basic;

#if macro
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import hex.collection.ILocator;
import hex.compiletime.flow.parser.ExpressionUtil;
import hex.core.ICoreFactory;
import hex.di.mapping.MappingChecker;
import hex.di.mapping.MappingDefinition;
import hex.util.MacroUtil;
import hex.vo.ConstructorVO;

using Lambda;

/**
 * ...
 * @author Francis Bourre
 */
class MappingDependencyChecker 
{
	var _coreFactory 			: ICoreFactory;
	var _typeLocator 			: ILocator<String, String>;
	var _dependencyInterface 	: ClassType;
	
	public function new( coreFactory : ICoreFactory, typeLocator : ILocator<String, String> ) 
	{
		this._coreFactory 			= coreFactory;
		this._typeLocator 			= typeLocator;
		this._dependencyInterface 	= MacroUtil.getClassType( Type.getClassName( hex.di.mapping.IDependencyOwner ) );
	}
	
	public function checkDependencies( constructorVO : ConstructorVO ) : Void
	{
		if ( MacroUtil.implementsInterface( MacroUtil.getClassType( constructorVO.className, null, false ), _dependencyInterface ) )
		{
			var mappings = constructorVO.arguments
				.filter( function ( arg ) return arg.ref != null )
					.filter( function ( arg ) return this._coreFactory.isRegisteredWithKey( arg.ref ) )
						.map( function ( arg ) return {pos: arg.filePosition, expr: this._coreFactory.locate( arg.ref )} )
							.filter( function ( arg ) return arg.expr != null )
								.flatMap( function( arg ) return _getMappingDefinitions( arg.expr, arg.pos ) )
									.array();
			
			if ( constructorVO.ref == null && !MappingChecker.matchForClassName( constructorVO.className, mappings ) )
			{
				var missingMappings = MappingChecker.getMissingMapping( constructorVO.className, mappings );
				Context.fatalError( "Missing mappings:" + missingMappings, constructorVO.filePosition );
			}
		}
	}
	
	function _getMappingDefinitions( e : Expr, filePosition ) : Array<MappingDefinition>
	{
		var a = [];
		switch( e.expr )
		{
			case EVars( vars ) :
				if ( vars[ 0 ].type != null )
				{
					if ( ComplexTypeTools.toString( vars[ 0 ].type ) == 'Array<hex.di.mapping.MappingDefinition>' )
					{
						switch( vars[ 0 ].expr.expr )
						{
							case EArrayDecl( values ):
								for ( value in values ) 
								{
									switch( value.expr )
									{
										case EObjectDecl( fields ):
											var mapping = _getMappingDefinition( value, filePosition );
											if ( mapping != null ) a.push( mapping );
											
										case EConst(CIdent(ident)):
											a = a.concat( _getMappingDefinitions( this._coreFactory.locate( ident ), filePosition ) );
											
										case wtf:
											trace( 'wtf', wtf );
									}
								}

							case _:
						}
						
					}
					else if ( ComplexTypeTools.toString( vars[ 0 ].type ) == 'hex.di.mapping.MappingDefinition' )
					{
						var mapping = _getMappingDefinition( vars[ 0 ].expr, filePosition );
						if ( mapping != null ) a.push( mapping );
					}
				}
				
			case _:
		}
		
		return cast a;
	}
	
	public function _getMappingDefinition( e, filePosition )
	{
		var _getDefinition = function( e )
		{
			switch( e.expr )
			{
				case EObjectDecl( fields ):

					return fields.fold ( 
						function (f, o) 
						{
							switch( f.field )
							{
								case 'fromType': Reflect.setField( o, f.field, haxe.macro.ExprTools.getValue( f.expr ) );
								case 'withName': Reflect.setField( o, f.field, haxe.macro.ExprTools.getValue( f.expr ) );
								case _:
							}
							return o;
						}, {} );

				case _:
			}
			
			return null;
		};
		
		var throwError = function( filePosition, typeToMatch, hasToMatch )
		{
			var toString = haxe.macro.TypeTools.toString;
			Context.error( "Type mismatch in your mapping definition.\n'" +
				toString( hasToMatch ) + "' doesn't match with '" + toString( typeToMatch )
				+ "'", filePosition );
		}
	
		//We get mapping definition from the local function
		var md =  _getDefinition( e );
		
		//Now we start to check mapping consistency. 
		//The concrete type should unify with the abstract one.
		var fromType = _getField( e, 'fromType' );
		
		if ( fromType != null )
		{
			//Check for Class mapping
			var typeName = switch( fromType.expr ) { case EConst(CString(typeName)): typeName; case _: null; };
			var toValue = _getField( e, 'toValue' ); 
			var toClass = _getField( e, 'toClass' );

			if ( toClass != null )
			{
				var className = ExpressionUtil.compressField( toClass );
				if ( typeName != null && className != null )
				{
					var typeToMatch = MacroUtil.getTypeFromString( typeName );
					var hasToMatch = Context.getType( className );

					if ( !Context.unify( hasToMatch, typeToMatch ) )
					{
						throwError( filePosition, typeToMatch, hasToMatch );
					}
				}
			}
			else if ( toValue != null )
			{
				//Check for value
				try
				{
					var value = haxe.macro.ExprTools.getValue( toValue );
					var typeToMatch = MacroUtil.getTypeFromString( typeName );
					var hasToMatch = Context.typeof( toValue );

					if ( !Context.unify( hasToMatch, typeToMatch ) )
					{
						throwError( filePosition, typeToMatch, hasToMatch );
					}
				}
				//Check for reference
				catch ( err : Dynamic )
				{
					var compressedField = new haxe.macro.Printer().printExpr( toValue );
					if ( compressedField != null && this._typeLocator.isRegisteredWithKey( compressedField ) )
					{
						var typeLoc = this._typeLocator.locate( compressedField );
						var typeToMatch = MacroUtil.getTypeFromString( typeName );

						var hasToMatch = try
						{
							Context.getType( typeLoc );
							
						}
						catch ( e : Dynamic )
						{
							Context.typeof(Context.parseInlineString( '( null : ${typeLoc})', filePosition ));
						}
						
						if ( !Context.unify( hasToMatch, typeToMatch ) )
						{
							throwError( filePosition, typeToMatch, hasToMatch );
						}
					}
				}
			}
		}
		
		return md;
	}
	
	function _getField( e, fieldName )
	{
		switch( e.expr )
		{
			case EObjectDecl( fields ):

				for ( f in fields )
				{
					if ( f.field == fieldName )
					{
						switch( f.expr.expr )
						{
							case EConst(CIdent('null')): return null;
							case _ : return f.expr;
						}
					}
				}
			case _:
		}
		return null;
	}
}
#end