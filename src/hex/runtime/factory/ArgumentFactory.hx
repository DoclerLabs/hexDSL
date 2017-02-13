package hex.runtime.factory;

import hex.error.PrivateConstructorException;
import hex.runtime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class ArgumentFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }

	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Array<Dynamic>
	{
		var factory 		= factoryVO.contextFactory;
		var cons 			= factoryVO.constructorVO;
		var result 			= [];
		
		for ( arg in cons.arguments )
			result.push( factory.buildVO( arg ) );

		return result;
	}
}