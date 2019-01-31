package hex.runtime.factory;

import hex.runtime.basic.vo.FactoryVOTypeDef;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class UIntFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : UInt
	{
		var result 	: UInt 	= 0;
		var constructorVO 	= factoryVO.constructorVO;
		var args 			= constructorVO.arguments;
		

		if ( args != null && args.length > 0 ) 
		{
			result = Std.parseInt( Std.string( args[ 0 ] ) );
		}
		else
		{
			throw new IllegalArgumentException( "UIntFactory.build(" + ( args != null && args.length > 0 ? args[ 0 ] : "" ) + ") failed." );
		}
		
		#if js
		if ( result == null || result < 0 )
		#else
		if ( "" + result != args[ 0 ] && '0x' + StringTools.hex( result, 6 ) != args[ 0 ] && result >= 0 )
		#end
		{
			throw new IllegalArgumentException( "UIntFactory.build(" + result + ") failed." );
		}
		
		return result;
	}
}