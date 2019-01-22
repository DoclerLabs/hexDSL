package hex.runtime.factory;

import hex.runtime.basic.vo.FactoryVOTypeDef;

using hex.error.Error;

#if debug
import hex.log.HexLog.*;
#end
/**
 * ...
 * @author Francis Bourre
 */
class StringFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
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
			warn( "StringFactory.build(" + result + ") returns empty String." );
			#end
		}

		return result;
	}
}