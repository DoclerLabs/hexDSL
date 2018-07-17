package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import hex.compiletime.factory.ArgumentFactory;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ClassInstanceFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();

	static var _fqcn = MacroUtil.getFQCNFromExpression;
	static inline function _staticRefFactory( tp, staticRef, factoryMethod, args ) return macro $p{ tp }.$staticRef.$factoryMethod( $a{ args } );
	static inline function _staticCallFactory( tp, staticCall, factoryMethod, args ) return macro $p{ tp }.$staticCall().$factoryMethod( $a{ args } );
	static inline function _staticCall( tp, staticCall, args ) return macro $p{ tp }.$staticCall( $a{ args } );
	static inline function _nullArray( length : UInt ) return  [ for ( i in 0...length ) macro null ];
	static inline function _implementsInterface( classRef, interfaceRef ) return  MacroUtil.implementsInterface( classRef, MacroUtil.getClassType( Type.getClassName( interfaceRef ) ) );
	static inline function _varType( type, position ) return TypeTools.toComplexType( Context.typeof( Context.parseInlineString( '( null : ${type})', position ) ) );
	static inline function _blankType( vo ) { vo.cType = tink.macro.Positions.makeBlankType( vo.filePosition ); return MacroUtil.getFQCNFromComplexType( vo.cType ); }
	
	public static inline function getResult( e, id, vo ) 
	{
		return if ( vo.shouldAssign && !vo.lazy )
		{
			var t = vo.cType != null ? vo.cType : _varType( vo.type, vo.filePosition ); 
			macro @:pos( vo.filePosition ) var $id : $t = $e;
			
		} else e;
	}
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		return _build( factoryVO, 
			function( typePath, args, id, vo )
			{
				var t =  Context.getType( typePath.pack.join('.') + '.' + typePath.name );
				switch( t )
				{
					case TInst( t, params ): if ( !t.get().constructor.get().isPublic ) 
						Context.error( 'WTF, you try to instantiate a class with a private constructor!', vo.filePosition );
					case _:
				}
				
				return getResult( macro new $typePath( $a { args } ), id, vo );
			}
		);
	}
	
	static public function _build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T, elseDo ) : Expr
	{
		var vo 				= factoryVO.constructorVO;
		var pos 			= vo.filePosition;
		var id 				= vo.ID;
		var args 			= ArgumentFactory.build( factoryVO );
		var pack 			= MacroUtil.getPack( vo.className, pos );
		var typePath 		= MacroUtil.getTypePath( vo.className, pos );
		var staticCall 		= vo.staticCall;
		var factoryMethod 	= vo.factory;
		var staticRef 		= vo.staticRef;
		var classType 		= MacroUtil.getClassType( vo.className, pos );

		/*if ( !vo.shouldAssign && !vo.lazy )//TODO remove
		{
			return macro @:pos( pos ) new $typePath( $a { args } );
		}
		else
		{*/
			var result = //Assign result
			if ( factoryMethod != null )//factory method
			{
				//TODO implement the same behavior @runtime issue#1
				if ( staticRef != null )//static variable - with factory method
				{
					var e = _staticRefFactory( pack, staticRef, factoryMethod, args );
					vo.type = vo.abstractType != null ? vo.abstractType : 
						try _fqcn( e ) catch ( e : Dynamic ) _blankType( vo );
					getResult( e, id, vo );
				}
				else if ( staticCall != null )//static method call - with factory method
				{
					var e = _staticCallFactory( pack, staticCall, factoryMethod, args );
					vo.type = vo.abstractType != null ? vo.abstractType : 
						try _fqcn( e ) catch ( e : Dynamic ) _blankType( vo );
					
					getResult( e, id, vo );
				}
				else//factory method error
				{
					Context.error( 	"'" + factoryMethod + "' method cannot be called on '" +  vo.className + 
									"' class. Add static method or variable to make it working.", pos );
				}
			}
			else if ( staticCall != null )//simple static method call
			{
				var e = _staticCall( pack, staticCall, args );
				vo.type = vo.abstractType != null ? vo.abstractType : 
					try _fqcn( e ) catch ( e : Dynamic ) _blankType( vo );

				getResult( e, id, vo );
			}
			else//Standard instantiation
			{
				elseDo( typePath, args, id, vo );
			}

			return macro @:pos(pos) $result;
		/*}*/
	}
}
#end