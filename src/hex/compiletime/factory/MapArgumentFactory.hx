package hex.compiletime.factory;

#if macro
import hex.vo.MapVO;

/**
 * ...
 * @author Francis Bourre
 */
class MapArgumentFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();

	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Array<MapVO>
	{
		var result 				= [];
		var factory 			= factoryVO.contextFactory;
		var constructorVO 		= factoryVO.constructorVO;
		var args : Array<MapVO>	= cast constructorVO.arguments;
		
		if ( args != null ) for ( mapVO in args )
		{
			mapVO.key 			= factory.buildVO( mapVO.getPropertyKey() );
			mapVO.value 		= factory.buildVO( mapVO.getPropertyValue() );
			result.push( mapVO );
		}
		
		return result;
	}
}
#end