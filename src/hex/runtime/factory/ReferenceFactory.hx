package hex.runtime.factory;

import hex.error.PrivateConstructorException;
import hex.runtime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class ReferenceFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Dynamic
	{
		var result : Dynamic 	= null;
		var constructorVO 		= factoryVO.constructorVO;
		var key 				= constructorVO.ref;
		var coreFactory			= factoryVO.contextFactory.getCoreFactory();

		if ( key.indexOf(".") != -1 )
		{
			key = Std.string( ( key.split( "." ) ).shift() );
		}
		
		if ( key == "this" )
		{
			key = factoryVO.contextFactory.getApplicationContext().getName();
		}

		if ( !( coreFactory.isRegisteredWithKey( key ) ) )
		{
			factoryVO.contextFactory.buildObject( key );
		}
		
		if ( constructorVO.ref.indexOf( "." ) != -1 )
		{
			var args = constructorVO.ref.split( "." );
			args.shift();
			result = coreFactory.fastEvalFromTarget( coreFactory.locate( key ), args.join( "." )  );
		}
		else 
		{
			result = coreFactory.locate( key );
		}
		
		return result; 
	}
}