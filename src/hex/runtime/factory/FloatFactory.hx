package hex.runtime.factory;

import hex.runtime.basic.vo.FactoryVOTypeDef;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class FloatFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Float
	{
		var result : Dynamic 	= Math.NaN;
		var constructorVO 		= factoryVO.constructorVO;
		var args 				= constructorVO.arguments;

		if ( args != null && args.length > 0 ) 
		{
			result = Std.parseFloat( args[ 0 ] );
		}

		if ( Math.isNaN( result ) )
		{
			throw new IllegalArgumentException( "FloatFactory.build(" + result + ") failed." );
		}
		
		return result;
	}
}