package hex.compiletime.factory;

#if macro
import haxe.macro.*;

/**
 * ...
 * @author Francis Bourre
 */
class NullFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = null:
			macro @:pos( constructorVO.filePosition ) null;
	}
}
#end