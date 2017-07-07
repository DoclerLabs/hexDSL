package hex.compiletime.factory;

#if macro
import haxe.macro.*;

/**
 * ...
 * @author Francis Bourre
 */
class FunctionFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 	= factoryVO.constructorVO;
		var coreFactory		= factoryVO.contextFactory.getCoreFactory();
		return null;
	}
}
#end