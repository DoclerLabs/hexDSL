package hex.runtime.factory;

import hex.runtime.basic.vo.FactoryVOTypeDef;
import hex.util.ClassUtil;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class StaticVariableFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Dynamic
	{ 
		return ClassUtil.getStaticVariableReference( factoryVO.constructorVO.staticRef );
	}
}