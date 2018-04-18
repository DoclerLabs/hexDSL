package hex.compiletime.basic;

#if macro
import hex.collection.Locator;
import hex.compiletime.basic.vo.FactoryVOTypeDef;
import hex.core.IApplicationContext;
import hex.core.ICoreFactory;
import hex.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class StaticCompileTimeContextFactory extends CompileTimeContextFactory
{
	static var _coreFactories : Map<String, ICoreFactory> = new Map();
	
	override public function init( applicationContext : IApplicationContext ) : Void
	{
		if ( !this._isInitialized )
		{
			this._isInitialized = true;
			
			this._applicationContext 				= applicationContext;
			this._coreFactory 						= applicationContext.getCoreFactory();

			if ( !StaticCompileTimeContextFactory._coreFactories.exists( applicationContext.getName() ) )
			{
				StaticCompileTimeContextFactory._coreFactories.set( this._applicationContext.getName(), cast ( applicationContext.getCoreFactory(), CompileTimeCoreFactory ) );
			}
			
			this._coreFactory = StaticCompileTimeContextFactory._coreFactories.get( this._applicationContext.getName() );

			this._constructorVOLocator 				= new Locator();
			this._propertyVOLocator 				= new Locator();
			this._methodCallVOLocator 				= new Locator();
			this._typeLocator 						= new Locator();
			this._moduleLocator 					= new Locator();
			this._mappedTypes 						= [];
			this._injectedInto 						= [];
			this._factoryMap 						= hex.compiletime.basic.BasicCompileTimeSettings.factoryMap;
			this._dependencyChecker					= new MappingDependencyChecker( this._coreFactory, this._typeLocator );
			this._coreFactory.addListener( this );
		}
	}
	
	override function _buildVO( constructorVO : ConstructorVO, id : String, result : Any ) : Void
	{
		this._tryToRegisterModule( constructorVO );
		this._parseInjectInto( constructorVO );
		this._parseMapTypes( constructorVO );
		
		var finalResult = result;
		finalResult = this._parseAutoInject( constructorVO, finalResult );

		var type = 
		if ( constructorVO.abstractType != null ) 	ContextFactoryUtil.getComplexType( constructorVO.abstractType, constructorVO.filePosition );
			else if ( constructorVO.cType != null ) constructorVO.cType;
				else 								ContextFactoryUtil.getComplexType( constructorVO.type, constructorVO.filePosition );

		//We need to unregister previous type and register the abstract type
		//For future checkings (ie: Mapping checking)
		if ( constructorVO.abstractType != null )
		{
			this._typeLocator.unregister( id );
			this._typeLocator.register( id, constructorVO.abstractType );
		}

		if ( constructorVO.isPublic || constructorVO.lazy )
		{
			hex.compiletime.util.ContextBuilder.getInstance( this )
				.addField( id, type, constructorVO.filePosition, (constructorVO.lazy?finalResult:null), constructorVO.isPublic );

			if ( !constructorVO.lazy )
			{
				this._expressions.push( macro @:mergeBlock { $finalResult;  /*coreFactory.register( $v { id }, $i { id } );*/ this.$id = $i { id }; } );
			}
		}
		else
		{
			this._expressions.push( macro @:mergeBlock { $finalResult;  /*coreFactory.register( $v { id }, $i { id } );*/ } );
		}
		
		this._coreFactory.register( id, result );
	}
}
#end