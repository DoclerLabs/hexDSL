package hex.compiletime.factory;

#if macro
import haxe.macro.Expr;
import hex.error.Exception;
import hex.error.PrivateConstructorException;
import hex.vo.ConstructorVO;
import hex.compiletime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class FunctionFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 	= factoryVO.constructorVO;
		var coreFactory		= factoryVO.contextFactory.getCoreFactory();

		var method : Dynamic;

		return method;
	}
}
#end