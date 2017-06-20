package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Francis Bourre
 */
class AliasFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		
		var value;
		var type;
		
		if ( !factoryVO.contextFactory.getTypeLocator().isRegisteredWithKey( constructorVO.ref ) )
		{
			value = factoryVO.contextFactory.buildVO( constructorVO.arguments[ 0 ] );
			type = factoryVO.contextFactory.getTypeLocator().locate( constructorVO.ref );
		}
		else
		{
			type = factoryVO.contextFactory.getTypeLocator().locate( constructorVO.ref );
			value = macro $i{ constructorVO.ref };
		}
		
		constructorVO.type = type;
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $value:
			macro @:pos( constructorVO.filePosition ) $value;	
	}
}
#end