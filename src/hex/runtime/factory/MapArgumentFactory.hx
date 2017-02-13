package hex.runtime.factory;

import hex.error.PrivateConstructorException;
import hex.runtime.basic.vo.FactoryVOTypeDef;
import hex.vo.MapVO;

/**
 * ...
 * @author Francis Bourre
 */
class MapArgumentFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }

	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Array<MapVO>
	{
		var result 				= [];
		var factory 			= factoryVO.contextFactory;
		var constructorVO 		= factoryVO.constructorVO;
		var args : Array<MapVO>	= cast constructorVO.arguments;
		
		for ( mapVO in args )
		{
			mapVO.key 			= factory.buildVO( mapVO.getPropertyKey() );
			mapVO.value 		= factory.buildVO( mapVO.getPropertyValue() );
			result.push( mapVO );
		}
		
		return result;
	}
}