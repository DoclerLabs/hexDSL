package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Francis Bourre
 */
class ImportFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var result : Bool 		= false;
		
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $v{ result }:
			macro @:pos( constructorVO.filePosition ) $v{ result };	
	}
}
#end