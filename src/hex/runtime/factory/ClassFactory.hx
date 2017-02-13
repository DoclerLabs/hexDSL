package hex.runtime.factory;

import hex.error.IllegalArgumentException;
import hex.error.PrivateConstructorException;
import hex.runtime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class ClassFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException( "This class can't be instantiated." );
    }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Class<Dynamic>
	{
		var constructorVO 		= factoryVO.constructorVO;
		var result 				: Class<Dynamic>;
		var qualifiedClassName 	= "";
		
		var args = constructorVO.arguments;

		if ( args != null && args.length > 0 )
		{
			qualifiedClassName = "" + args[0];
		}

		try
		{
			result = Type.resolveClass( qualifiedClassName );
		}
		catch ( e : Dynamic )
		{
			result = null;
		}
		
		if ( result == null )
		{
			throw new IllegalArgumentException( "'" + qualifiedClassName + "' is not available" );
		}

		return result;
	}
}