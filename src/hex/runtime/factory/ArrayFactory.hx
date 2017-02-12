package hex.runtime.factory;

import hex.error.PrivateConstructorException;
import hex.runtime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }

	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Array<Dynamic>
	{
		var constructorVO 		= factoryVO.constructorVO;
		var result 				= [];
		var args 				= ArgumentFactory.build( factoryVO );

		if ( args != null )
		{
			result = args.copy();
		}

		if ( constructorVO.mapTypes != null )
		{
			var mapTypes = constructorVO.mapTypes;
			for ( mapType in mapTypes )
			{
				//Remove whitespaces
				mapType = mapType.split( ' ' ).join( '' );
					
				factoryVO.contextFactory.getApplicationContext().getInjector()
					.mapClassNameToValue( mapType, result, constructorVO.ID );
			}
		}
		
		return result;
	}
}