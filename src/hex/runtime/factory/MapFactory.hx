package hex.runtime.factory;

import hex.error.PrivateConstructorException;
import hex.runtime.basic.vo.FactoryVOTypeDef;

#if debug
import hex.log.HexLog.*;
#end
/**
 * ...
 * @author Francis Bourre
 */
class MapFactory
{
	/** @private */
    function new() throw new PrivateConstructorException();

	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Map<Dynamic, Dynamic>
	{
		var constructorVO 	= factoryVO.constructorVO;
		var result 			= new Map<Dynamic, Dynamic>();
		var args 			= MapArgumentFactory.build( factoryVO );

		if ( args.length == 0 )
		{
			#if debug
			warn( "MapFactory.build(" + args + ") returns an empty Map." );
			#end

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					result.set( item.key, item.value );

				} else
				{
					#if debug
					info( "MapFactory.build() adds item with a 'null' key for '"  + item.value +"' value." );
					#end
				}
			}
		}

		return result;
	}
}