package hex.runtime.basic;

import hex.collection.ILocatorListener;
import hex.collection.Locator;
import hex.compiletime.basic.BuildRequest;
import hex.core.ApplicationAssemblerMessage;
import hex.core.ContextTypeList;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.domain.ApplicationDomainDispatcher;
import hex.event.IDispatcher;
import hex.runtime.basic.vo.FactoryVOTypeDef;
import hex.runtime.factory.ArrayFactory;
import hex.runtime.factory.BoolFactory;
import hex.runtime.factory.ClassFactory;
import hex.runtime.factory.ClassInstanceFactory;
import hex.runtime.factory.DynamicObjectFactory;
import hex.runtime.factory.FloatFactory;
import hex.runtime.factory.FunctionFactory;
import hex.runtime.factory.HashMapFactory;
import hex.runtime.factory.IntFactory;
import hex.runtime.factory.MappingConfigurationFactory;
import hex.runtime.factory.NullFactory;
import hex.runtime.factory.PropertyFactory;
import hex.runtime.factory.StaticVariableFactory;
import hex.runtime.factory.StringFactory;
import hex.runtime.factory.UIntFactory;
import hex.runtime.factory.XmlFactory;
import hex.vo.ConstructorVO;
import hex.vo.MethodCallVO;
import hex.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
@:keepSub
class RunTimeContextFactory 
	implements IBuilder<hex.compiletime.basic.BuildRequest>
	implements IRunTimeContextFactory 
	implements ILocatorListener<String, Dynamic>
{
	var _isInitialized				: Bool;
	
	var _contextDispatcher			: IDispatcher<{}>;
	var _applicationContext 		: IApplicationContext;
	var _factoryMap 				: Map<String, FactoryVOTypeDef->Dynamic>;
	var _coreFactory 				: IRunTimeCoreFactory;
	var _constructorVOLocator 		: Locator<String, ConstructorVO>;
	var _propertyVOLocator 			: Locator<String, Array<PropertyVO>>;
	var _methodCallVOLocator 		: Locator<String, MethodCallVO>;
	var _injectedInto				: Array<Any>;

	public function new()
	{
		this._isInitialized = false;
	}
	
	public function init( applicationContext : IApplicationContext ) : Void
	{
		if ( !this._isInitialized )
		{
			this._isInitialized = true;
			
			//settings
			this._applicationContext = applicationContext;
			this._contextDispatcher = ApplicationDomainDispatcher.getInstance( this._applicationContext ).getDomainDispatcher( applicationContext.getDomain() );
			var injector = this._applicationContext.getInjector();
			this._coreFactory = cast ( applicationContext.getCoreFactory(), IRunTimeCoreFactory );

			//initialization
			this._contextDispatcher.dispatch( ApplicationAssemblerMessage.CONTEXT_PARSED );
			
			//
			this._factoryMap 				= new Map();
			this._constructorVOLocator 		= new Locator();
			this._propertyVOLocator 		= new Locator();
			this._methodCallVOLocator 		= new Locator();
			this._injectedInto				= [];

			this._factoryMap.set( ContextTypeList.ARRAY, ArrayFactory.build );
			this._factoryMap.set( ContextTypeList.BOOLEAN, BoolFactory.build );
			this._factoryMap.set( ContextTypeList.INT, IntFactory.build );
			this._factoryMap.set( ContextTypeList.NULL, NullFactory.build );
			this._factoryMap.set( ContextTypeList.FLOAT, FloatFactory.build );
			this._factoryMap.set( ContextTypeList.OBJECT, DynamicObjectFactory.build );
			this._factoryMap.set( ContextTypeList.STRING, StringFactory.build );
			this._factoryMap.set( ContextTypeList.UINT, UIntFactory.build );
			this._factoryMap.set( ContextTypeList.DEFAULT, StringFactory.build );
			this._factoryMap.set( ContextTypeList.HASHMAP, HashMapFactory.build );
			this._factoryMap.set( ContextTypeList.CLASS, ClassFactory.build );
			this._factoryMap.set( ContextTypeList.XML, XmlFactory.build );
			this._factoryMap.set( ContextTypeList.FUNCTION, FunctionFactory.build );
			this._factoryMap.set( ContextTypeList.INSTANCE, ClassInstanceFactory.build );
			this._factoryMap.set( ContextTypeList.STATIC_VARIABLE, StaticVariableFactory.build );
			this._factoryMap.set( ContextTypeList.MAPPING_CONFIG, MappingConfigurationFactory.build );
			
			this._coreFactory.addListener( this );
		}
	}
	
	public function build( request : BuildRequest ) : Void
	{
		switch( request )
		{
			case PREPROCESS( vo ): this.preprocess( vo );
			case OBJECT( vo ): this.registerConstructorVO( vo );
			case PROPERTY( vo ): this.registerPropertyVO( vo );
			case METHOD_CALL( vo ): this.registerMethodCallVO( vo );
		}
	}
	
	public function finalize() : Void
	{
		this.dispatchAssemblingStart();
		this.buildAllObjects();
		this.callAllMethods();
		this.dispatchAssemblingEnd();
		this.dispatchIdleMode();
	}
	
	public function dispose() : Void
	{
		this._coreFactory.removeListener( this );
		this._coreFactory.clear();
		this._constructorVOLocator.release();
		this._propertyVOLocator.release();
		this._methodCallVOLocator.release();
		this._factoryMap = new Map();
		this._injectedInto = [];
	}
	
	public function getCoreFactory() : IRunTimeCoreFactory
	{
		return this._coreFactory;
	}
	
	public function dispatchAssemblingStart() : Void
	{
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.ASSEMBLING_START );
	}
	
	public function dispatchAssemblingEnd() : Void
	{
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.ASSEMBLING_END );
	}
	
	public function dispatchIdleMode() : Void
	{
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.IDLE_MODE );
	}
	
	//
	public function preprocess( vo : hex.vo.PreProcessVO ) : Void
	{
		//We don't have any preprocessor for now
	}
	
	public function registerPropertyVO( propertyVO : PropertyVO  ) : Void
	{
		var id = propertyVO.ownerID;
		
		if ( this._propertyVOLocator.isRegisteredWithKey( id ) )
		{
			this._propertyVOLocator.locate( id ).push( propertyVO );
		}
		else
		{
			this._propertyVOLocator.register( id, [ propertyVO ] );
		}
	}
	
	//listen to CoreFactory
	public function onRegister( key : String, instance : Dynamic ) : Void
	{
		if ( this._propertyVOLocator.isRegisteredWithKey( key ) )
		{
			var properties = this._propertyVOLocator.locate( key );
			for ( p in properties ) 
				PropertyFactory.build( this, p, instance );
		}
	}

    public function onUnregister( key : String ) : Void  { }
	
	//
	public function registerConstructorVO( constructorVO : ConstructorVO ) : Void
	{
		this._constructorVOLocator.register( constructorVO.ID, constructorVO );
	}
	
	public function buildObject( id : String ) : Void
	{
		if ( this._constructorVOLocator.isRegisteredWithKey( id ) )
		{
			this.buildVO( this._constructorVOLocator.locate( id ), id );
			this._constructorVOLocator.unregister( id );
		}
	}
	
	public function buildAllObjects() : Void
	{
		var keys : Array<String> = this._constructorVOLocator.keys();
		for ( key in keys )
		{
			this.buildObject( key );
		}
		
		if ( this._injectedInto.length > 0 )
		{
			var injector = this._applicationContext.getInjector();
			for ( element in this._injectedInto )
			{
				injector.injectInto( element );
			}
		}
		
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.OBJECTS_BUILT );
	}
	
	public function registerMethodCallVO( methodCallVO : MethodCallVO ) : Void
	{
		var index : Int = this._methodCallVOLocator.keys().length +1;
		this._methodCallVOLocator.register( "" + index, methodCallVO );
	}
	
	public function callMethod( id : String ) : Void
	{
		var method : MethodCallVO 	= this._methodCallVOLocator.locate( id );
		var cons = new ConstructorVO( null, ContextTypeList.FUNCTION, [ method.ownerID + "." + method.name ] );
		var func : Dynamic 			= this.buildVO( cons );
		
		var arguments = method.arguments;
		var l : Int = arguments.length;
		for ( i in 0...l )
		{
			arguments[ i ] = this.buildVO( arguments[ i ] );
		}
		
		Reflect.callMethod( this._coreFactory.locate( method.ownerID ), func, arguments );
	}

	public function callAllMethods() : Void
	{
		var keyList : Array<String> = this._methodCallVOLocator.keys();
		for ( key in keyList )
		{
			this.callMethod(  key );
		}
		
		this._methodCallVOLocator.clear();
		this._contextDispatcher.dispatch( ApplicationAssemblerMessage.METHODS_CALLED );
	}

	public function getApplicationContext() : IApplicationContext
	{
		return this._applicationContext;
	}

	public function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		var buildMethod : FactoryVOTypeDef->Dynamic = null;
		
		//TODO better type checking
		var type 			= constructorVO.className.split( "<" )[ 0 ];
		buildMethod 		= ( this._factoryMap.exists( type ) ) ? this._factoryMap.get( type ) : ClassInstanceFactory.build;
		
		//build instance with the expected factory method
		var result 	= buildMethod( this._getFactoryVO( constructorVO ) );
		
		//Mapped types
		if ( constructorVO.mapTypes != null )
		{
			var mapTypes = constructorVO.mapTypes;
			for ( mapType in mapTypes )
			{
				//Remove whitespaces
				mapType = mapType.split( ' ' ).join( '' );
				
				this.getApplicationContext().getInjector()
					.mapClassNameToValue( mapType, result, constructorVO.ID );
			}
		}

		//Inject into
		if ( constructorVO.injectInto )
		{
			this._injectedInto.push( result );
		}

		if ( id != null )
		{
			this._coreFactory.register( id, result );
		}

		return result;
	}
	
	function _getFactoryVO( constructorVO : ConstructorVO = null ) : FactoryVOTypeDef
	{
		return { constructorVO : constructorVO, contextFactory : this };
	}
}