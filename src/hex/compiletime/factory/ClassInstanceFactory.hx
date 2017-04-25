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
	static inline function _result( e, idVar, type, position ) { var t = _varType( type, position ); return macro @:pos( position ) var $idVar : $t = $e; }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var result : Expr 	= null;
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;
		var constructorArgs = ArgumentFactory.build( factoryVO );
		var tp 				= MacroUtil.getPack( constructorVO.className, constructorVO.filePosition );
		var typePath 		= MacroUtil.getTypePath( constructorVO.className, constructorVO.filePosition );
		var staticCall 		= constructorVO.staticCall;
		var factoryMethod 	= constructorVO.factory;
		var staticRef 		= constructorVO.staticRef;
		var classType 		= MacroUtil.getClassType( constructorVO.className, constructorVO.filePosition );

		if ( constructorVO.injectorCreation && _implementsInterface( classType, hex.di.IInjectorContainer )  )
		{
			result = macro 	@:pos( constructorVO.filePosition ) 
				var $idVar = __applicationContextInjector.instantiateUnmapped( $p { tp } ); 

		}
		else if ( factoryMethod != null )//factory method
		{
			//TODO implement the same behavior @runtime issue#1
			if ( staticRef != null )//static variable - with factory method
			{
				var e = _staticRefFactory( tp, staticRef, factoryMethod, constructorArgs );
				constructorVO.type = try _fqcn( result ) 
					catch ( e : Dynamic ) _fqcn( _staticRefFactory( tp, staticRef, factoryMethod, _nullArray( constructorArgs.length ) ) );
				result = _result( e, constructorVO.ID, constructorVO.type, constructorVO.filePosition );
			}
			else if ( staticCall != null )//static method call - with factory method
			{
				var e = _staticCallFactory( tp, staticCall, factoryMethod, constructorArgs );
				constructorVO.type = try _fqcn( result ) 
					catch ( e : Dynamic ) _fqcn( _staticCallFactory( tp, staticCall, factoryMethod, _nullArray( constructorArgs.length ) ) );
				result = _result( e, constructorVO.ID, constructorVO.type, constructorVO.filePosition );
			}
			else//factory method error
			{
				Context.error( 	"'" + factoryMethod + "' method cannot be called on '" +  constructorVO.className + 
								"' class. Add static method or variable to make it working.", constructorVO.filePosition );
			}
		}
		else if ( staticCall != null )//simple static method call
		{
			var e = _staticCall( tp, staticCall, constructorArgs );
			constructorVO.type = try _fqcn( result ) 
				catch ( e : Dynamic ) _fqcn( _staticCall( tp, staticCall, _nullArray( constructorArgs.length ) ) );
			result = _result( e, constructorVO.ID, constructorVO.type, constructorVO.filePosition );
		}
		else//Standard instantiation
		{
			result = _result( macro new $typePath( $a{ constructorArgs } ), constructorVO.ID, constructorVO.type, constructorVO.filePosition );
		}
		
		return macro @:pos( constructorVO.filePosition ) $result;
	}
}
#end