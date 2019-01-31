package hex.runtime.factory;

import hex.runtime.basic.vo.FactoryVOTypeDef;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactory
{
	/** @private */ function new() throw new PrivateConstructorException();

	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Array<Dynamic>
	{
		var constructorVO 		= factoryVO.constructorVO;
		var result 				= [];
		var args 				= ArgumentFactory.build( factoryVO );

		if ( args != null )
		{
			result = args.copy();
		}
		
		return result;
	}
}