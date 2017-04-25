package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import hex.compiletime.factory.ArgumentFactory;
import hex.error.PrivateConstructorException;
import hex.util.MacroUtil;
import hex.compiletime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class ClassInstanceFactory
{
	/** @private */
    function new() throw new PrivateConstructorException();

	static var _fqcn = MacroUtil.getFQCNFromExpression;
	static inline function _staticRefFactory( tp, staticRef, factoryMethod, args ) return macro $p{ tp }.$staticRef.$factoryMethod( $a{ args } );
	static inline function _staticCallFactory( tp, staticCall, factoryMethod, args ) return macro $p{ tp }.$staticCall().$factoryMethod( $a{ args } );
	static inline function _staticCall( tp, staticCall, args ) return macro $p{ tp }.$staticCall( $a{ args } );
	static inline function _nullArray( length : UInt ) return  [ for ( i in 0...length ) macro null ];
	static inline function _implementsInterface( classRef, interfaceRef ) return  MacroUtil.implementsInterface( classRef, MacroUtil.getClassType( Type.getClassName( interfaceRef ) ) );
	static inline function _varType( type, position ) return TypeTools.toComplexType( Context.typeof( Context.parseInlineString( '( null : ${type})', position ) ) );
	static inline function _result( e, id, type, position ) { var t = _varType( type, position ); return macro @:pos( position ) var $id : $t = $e; }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var result : Expr 	= null;
		var vo 				= factoryVO.constructorVO;
		var pos 			= vo.filePosition;
		var id 				= vo.ID;
		var args 			= ArgumentFactory.build( factoryVO );
		var argsLength 		= args.length;
		var pack 			= MacroUtil.getPack( vo.className, pos );
		var typePath 		= MacroUtil.getTypePath( vo.className, pos );
		var staticCall 		= vo.staticCall;
		var factoryMethod 	= vo.factory;
		var staticRef 		= vo.staticRef;
		var classType 		= MacroUtil.getClassType( vo.className, pos );

		if ( vo.injectorCreation && _implementsInterface( classType, hex.di.IInjectorContainer )  )
		{
			result = macro @:pos(pos) var $id = __applicationContextInjector.instantiateUnmapped( $p{ pack } ); 
		}
		else if ( factoryMethod != null )//factory method
		{
			//TODO implement the same behavior @runtime issue#1
			if ( staticRef != null )//static variable - with factory method
			{
				var e = _staticRefFactory( pack, staticRef, factoryMethod, args );
				vo.type = try _fqcn( result ) 
					catch ( e : Dynamic ) _fqcn( _staticRefFactory( pack, staticRef, factoryMethod, _nullArray( argsLength ) ) );
				result = _result( e, id, vo.type, pos );
			}
			else if ( staticCall != null )//static method call - with factory method
			{
				var e = _staticCallFactory( pack, staticCall, factoryMethod, args );
				vo.type = try _fqcn( result ) 
					catch ( e : Dynamic ) _fqcn( _staticCallFactory( pack, staticCall, factoryMethod, _nullArray( argsLength ) ) );
				result = _result( e, id, vo.type, pos );
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
			vo.type = try _fqcn( result ) 
				catch ( e : Dynamic ) _fqcn( _staticCall( pack, staticCall, _nullArray( argsLength ) ) );
			result = _result( e, id, vo.type, pos );
		}
		else//Standard instantiation
		{
			result = _result( macro new $typePath( $a{ args } ), id, vo.type, pos );
		}
		
		return macro @:pos(pos) $result;
	}
}
#end