package hex.runtime.factory;

import hex.di.mapping.MappingConfiguration;
import hex.error.PrivateConstructorException;
import hex.runtime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class MappingConfigurationFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }

	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : MappingConfiguration
	{
		var result = new MappingConfiguration();
		var args = MapArgumentFactory.build( factoryVO );

		if ( args.length <= 0 )
		{
			trace( "MappingConfigurationFactory.build(" + args + ") returns an empty congiuration." );

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					result.addMapping( item.key, item.value, item.mapName, item.asSingleton, item.injectInto );

				} else
				{
					trace( "MappingConfigurationFactory.build() adds item with a 'null' key for '"  + item.value +"' value." );
				}
			}
		}

		return result;
	}
}