package hex.compiletime.factory;

#if macro
import hex.error.PrivateConstructorException;
import hex.vo.MapVO;
import hex.compiletime.basic.vo.FactoryVOTypeDef;

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
#end