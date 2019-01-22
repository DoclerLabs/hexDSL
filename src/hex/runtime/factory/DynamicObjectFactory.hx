package hex.runtime.factory;

import hex.runtime.basic.vo.FactoryVOTypeDef;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class DynamicObjectFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
 
	static public function build<T:FactoryVOTypeDef>( factoryVO : T )
		return {};
}
