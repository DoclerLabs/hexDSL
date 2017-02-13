package hex.runtime.factory;

import hex.error.IllegalArgumentException;
import hex.error.PrivateConstructorException;
import hex.log.Logger;
import hex.runtime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class StringFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : String
	{
		var result : String 	= null;
		var constructorVO 		= factoryVO.constructorVO;
		var args 				= constructorVO.arguments;

		if ( args != null && args.length > 0 && args[ 0 ] != null )
		{
			result = Std.string( args[ 0 ] );
		}
		else
		{
			throw new IllegalArgumentException( "StringFactory.build(" + result + ") returns empty String." );
		}

		if ( result == null )
		{
			result = "";
			#if debug
			Logger.warn( "StringFactory.build(" + result + ") returns empty String." );
			#end
		}

		return result;
	}
}