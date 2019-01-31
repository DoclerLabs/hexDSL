package hex.runtime.factory;

import hex.runtime.basic.vo.FactoryVOTypeDef;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class BoolFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Bool
	{
		var result 			= false;
		var constructorVO 	= factoryVO.constructorVO;
		var value 			= "";
		var args 			= constructorVO.arguments;

		if ( args != null && args.length > 0 ) 
		{
			value = args[0];
		}
		
		if ( value == "true" )
		{
			result = true;
		}
		else if ( value == "false" )
		{
			result = false;
		}
		else
		{
			throw new IllegalArgumentException( "BoolFactory.build(" + value + ") failed." );
		}
		
		return result;
	}
}