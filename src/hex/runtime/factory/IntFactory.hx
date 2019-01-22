package hex.runtime.factory;

import hex.runtime.basic.vo.FactoryVOTypeDef;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class IntFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Int
	{
		var constructorVO 	= factoryVO.constructorVO;
		var args 			= constructorVO.arguments;
		var result 	: Int 	= 0;

		if ( args != null && args.length > 0 ) 
		{
			result = Std.parseInt( Std.string( args[ 0 ] ) );
		}
		else
		{
			throw new IllegalArgumentException( "IntFactory.build(" + ( args != null && args.length > 0 ? args[0] : "" ) + ") failed." );
		}

		// neko doesnt support null in StringTools.hex();
		#if (js || neko)
		if ( result == null )
		#else
		if ( "" + result != args[ 0 ] && '0x' + StringTools.hex( result, 6 ) != args[ 0 ] )
		#end
		{
			throw new IllegalArgumentException( "IntFactory.build(" + result + ") failed." );
		}
		
		return result;
	}
}