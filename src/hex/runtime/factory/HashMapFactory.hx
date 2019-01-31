package hex.runtime.factory;

import hex.collection.HashMap;
import hex.runtime.basic.vo.FactoryVOTypeDef;

#if debug
import hex.log.HexLog.*;
#end

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class HashMapFactory
{
	/** @private */ function new() throw new PrivateConstructorException();

	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : HashMap<Dynamic, Dynamic>
	{
		var constructorVO 	= factoryVO.constructorVO;
		var result 			= new HashMap<Dynamic, Dynamic>();
		var args 			= MapArgumentFactory.build( factoryVO );

		if ( args.length == 0 )
		{
			#if debug
			warn( "HashMapFactory.build(" + args + ") returns an empty HashMap." );
			#end

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					result.put( item.key, item.value );

				} else
				{
					#if debug
					info( "HashMapFactory.build() adds item with a 'null' key for '"  + item.value +"' value." );
					#end
				}
			}
		}

		return result;
	}
}