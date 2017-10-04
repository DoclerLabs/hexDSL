package hex.runtime.factory;

import hex.error.PrivateConstructorException;
import hex.runtime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class DynamicObjectFactory
{
	/** @private */
    function new() throw new PrivateConstructorException();
 
	static public function build<T:FactoryVOTypeDef>( factoryVO : T )
		return {};
}
