package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiletime.basic.vo.FactoryVOTypeDef;
import hex.di.mapping.MappingConfiguration;
import hex.error.PrivateConstructorException;
import hex.util.MacroUtil;
import hex.vo.MapVO;

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
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= MappingConfigurationFactory._buildArgs( factoryVO );
		
		var typePath 			= MacroUtil.getTypePath( Type.getClassName( MappingConfiguration ) );
		var e 					= macro @:pos( constructorVO.filePosition ) { new $typePath(); };

		if ( constructorVO.shouldAssign )
		{
			var result 	= macro @:pos( constructorVO.filePosition ) var $idVar = $e;
			
			if ( args.length == 0 )
			{
				#if debug
				Context.warning( "Empty MappingConfiguration built.", constructorVO.filePosition );
				#end

			} else
			{
				for ( item in args )
				{
					if ( item.key != null )
					{
						var a = [ macro { $v{ item.key } }, item.value, macro { $v{ item.mapName } }, macro { $v{ item.asSingleton } }, macro { $v{ item.injectInto } } ];

						//Fill with arguments
						result = macro 	@:pos( constructorVO.filePosition ) 
						@:mergeBlock 
						{
							$result; 
							$i{ idVar }.addMappingWithClassName( $a{ a } );
						}
						
					} else
					{
						#if debug
						Context.warning( "'null' key for value '"  + item.value +"' added.", constructorVO.filePosition );
						#end
					}
				}
			}
			
			return result;
		}
		else
		{
			return macro @:pos( constructorVO.filePosition ) $e;
		}
	}
	
	static function _buildArgs<T:FactoryVOTypeDef>( factoryVO : T ) : Array<MapVO>
	{
		var result 				= [];
		var factory 			= factoryVO.contextFactory;
		var constructorVO 		= factoryVO.constructorVO;
		var args : Array<MapVO>	= cast constructorVO.arguments;
		
		for ( mapVO in args )
		{
			mapVO.key 			= mapVO.getPropertyKey().ref != null ? mapVO.getPropertyKey().ref : mapVO.getPropertyKey().arguments[ 0 ];
			mapVO.value 		= factory.buildVO( mapVO.getPropertyValue() );
			result.push( mapVO );
		}
		
		return result;
	}
}
#end