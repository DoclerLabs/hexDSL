package hex.compiletime.factory;

#if macro
import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.util.MacroUtil;
import hex.compiletime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class StaticVariableFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		
		//Building result
		var result	= MacroUtil.getStaticVariable( constructorVO.staticRef, constructorVO.filePosition );
		
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $result:
			macro @:pos( constructorVO.filePosition ) $result;
	}
}
#end