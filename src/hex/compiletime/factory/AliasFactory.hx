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
			type = _getType( factoryVO, constructorVO.ref );
		}
		else
		{
			type = _getType( factoryVO, constructorVO.ref );
			value = macro @:pos( constructorVO.filePosition ) $i{ constructorVO.ref };
		}
		
		constructorVO.type = type;
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $value:
			macro @:pos( constructorVO.filePosition ) $value;	
	}
	
	static function _getType( factoryVO, ref : String )
	{
		return 
		if ( factoryVO.contextFactory.getTypeLocator().isRegisteredWithKey( ref ) )
		{
			factoryVO.contextFactory.getTypeLocator().locate( ref );
		}
		else
		{
			//TODO Find a better way to resolve final type
			'Dynamic';
		}
	}
}
#end