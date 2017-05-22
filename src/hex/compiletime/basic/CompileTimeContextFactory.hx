package hex.compiletime.basic;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import hex.collection.Locator;
import hex.compiletime.basic.vo.FactoryVOTypeDef;
import hex.compiletime.factory.FactoryUtil;
import hex.compiletime.factory.PropertyFactory;
import hex.core.ContextTypeList;
import hex.core.IApplicationContext;
import hex.core.ICoreFactory;
import hex.event.IDispatcher;
import hex.util.MacroUtil;
import hex.vo.ConstructorVO;
import hex.vo.MethodCallVO;
import hex.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeContextFactory 
	implements hex.core.IBuilder<BuildRequest>
	implements hex.compiletime.basic.IContextFactory 
	implements hex.collection.ILocatorListener<String, Dynamic>
{
	var _injectorContainerInterface : ClassType;
	var _moduleInterface 			: ClassType;
	
	var _isInitialized				: Bool;
	var _expressions 				: Array<Expr>;
	var _mappedTypes 				: Array<Expr>;
	var _injectedInto 				: Array<Expr>;
	
	var _contextDispatcher			: IDispatcher<{}>;
	var _moduleLocator				: Locator<String, String>;
	var _applicationContext 		: IApplicationContext;
	var _factoryMap 				: Map<String, FactoryVOTypeDef->Dynamic>;
	var _coreFactory 				: ICoreFactory;
	var _constructorVOLocator 		: Locator<String, ConstructorVO>;
	var _propertyVOLocator 			: Locator<String, Array<PropertyVO>>;
	var _methodCallVOLocator 		: Locator<String, MethodCallVO>;
	
	public function new( expressions : Array<Expr> )
	{
		this._expressions 					= expressions;
		this._isInitialized 				= false;
		this._injectorContainerInterface 	= MacroUtil.getClassType( Type.getClassName( hex.di.IInjectorContainer ) );
		this._moduleInterface 				= MacroUtil.getClassType( Type.getClassName( hex.module.IContextModule ) );
	}
	
	public function init( applicationContext : IApplicationContext ) : Void
	{
		if ( !this._isInitialized )
		{
			this._isInitialized = true;
			
			this._applicationContext 				= applicationContext;
			this._coreFactory 						= applicationContext.getCoreFactory();
			this._coreFactory.register( this._applicationContext.getName(), this._applicationContext );

			this._factoryMap 						= new Map();
			this._constructorVOLocator 				= new Locator();
			this._propertyVOLocator 				= new Locator();
			this._methodCallVOLocator 				= new Locator();
			this._moduleLocator 					= new Locator();
			this._mappedTypes 						= [];
			this._injectedInto 						= [];
		
			this._factoryMap.set( ContextTypeList.ARRAY, 			hex.compiletime.factory.ArrayFactory.build );
			this._factoryMap.set( ContextTypeList.BOOLEAN, 			hex.compiletime.factory.BoolFactory.build );
			this._factoryMap.set( ContextTypeList.INT, 				hex.compiletime.factory.IntFactory.build );
			this._factoryMap.set( ContextTypeList.NULL, 			hex.compiletime.factory.NullFactory.build );
			this._factoryMap.set( ContextTypeList.FLOAT, 			hex.compiletime.factory.FloatFactory.build );
			this._factoryMap.set( ContextTypeList.OBJECT, 			hex.compiletime.factory.DynamicObjectFactory.build );
			this._factoryMap.set( ContextTypeList.STRING, 			hex.compiletime.factory.StringFactory.build );
			this._factoryMap.set( ContextTypeList.UINT, 			hex.compiletime.factory.UIntFactory.build );
			this._factoryMap.set( ContextTypeList.DEFAULT, 			hex.compiletime.factory.StringFactory.build );
			this._factoryMap.set( ContextTypeList.HASHMAP, 			hex.compiletime.factory.HashMapFactory.build );
			this._factoryMap.set( ContextTypeList.CLASS, 			hex.compiletime.factory.ClassFactory.build );
			this._factoryMap.set( ContextTypeList.XML, 				hex.compiletime.factory.XmlFactory.build );
			this._factoryMap.set( ContextTypeList.FUNCTION, 		hex.compiletime.factory.FunctionFactory.build );
			this._factoryMap.set( ContextTypeList.STATIC_VARIABLE, 	hex.compiletime.factory.StaticVariableFactory.build );
			this._factoryMap.set( ContextTypeList.MAPPING_CONFIG, 	hex.compiletime.factory.MappingConfigurationFactory.build );
			
			this._coreFactory.addListener( this );
		}
	}

	public function build( request : BuildRequest ) : Void
	{
		switch( request )
		{
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
		this.callModuleInitialisation();
		this.dispatchAssemblingEnd();
	}
	
	public function dispose() : Void
	{
		this._coreFactory.removeListener( this );
		this._coreFactory.clear();
		this._constructorVOLocator.release();
		this._propertyVOLocator.release();
		this._methodCallVOLocator.release();
		this._moduleLocator.release();
		this._factoryMap = new Map();
		this._mappedTypes = [];
		this._injectedInto = [];
	}
	
	public function getCoreFactory() : ICoreFactory
	{
		return this._coreFactory;
	}
	
	public function dispatchAssemblingStart() : Void
	{
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.ASSEMBLING_START" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}
	
	public function dispatchAssemblingEnd() : Void
	{
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.ASSEMBLING_END" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}
	
	public function dispatchIdleMode() : Void
	{
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.IDLE_MODE" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}
	
	//
	public function registerPropertyVO( propertyVO : PropertyVO ) : Void
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
			this._propertyVOLocator.locate( key )
				.map( function( property ) this._expressions.push( macro @:mergeBlock ${ PropertyFactory.build( this, property ) } ) );
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
		this._constructorVOLocator.keys().map( this.buildObject );
		
		//Append to final expressions stack
		this._mappedTypes.map( this._expressions.push );
		this._injectedInto.map( this._expressions.push );
		
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.OBJECTS_BUILT" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}
	
	public function registerMethodCallVO( methodCallVO : MethodCallVO ) : Void
	{
		var index : Int = this._methodCallVOLocator.keys().length +1;
		this._methodCallVOLocator.register( "" + index, methodCallVO );
	}
	
	public function callMethod( id : String ) : Void
	{
		var method 			= this._methodCallVOLocator.locate( id );
		var methodName 		= method.name;
		var cons 			= new ConstructorVO( null, ContextTypeList.FUNCTION, [ method.ownerID + "." + methodName ] );
		var func : Dynamic 	= this.buildVO( cons );
		var arguments 		= method.arguments;

		var idArgs = method.ownerID + "_" + method.name + "Args";
		var varIDArgs = macro $i { idArgs };

		var l : Int = arguments.length;
		var args = [ for ( i in 0...l ) this.buildVO( arguments[ i ] ) ];
		
		var varOwner = macro $i{ method.ownerID };
		this._expressions.push( macro @:mergeBlock { $varOwner.$methodName( $a{ args } ); } );
	}

	public function callAllMethods() : Void
	{
		for ( key in this._methodCallVOLocator.keys() ) this.callMethod(  key );
		this._methodCallVOLocator.clear();
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.METHODS_CALLED" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}
	
	public function callModuleInitialisation() : Void
	{
		for ( moduleName in this._moduleLocator.values() ) this._expressions.push( macro @:mergeBlock { $i{moduleName}.initialize(); } );
		this._moduleLocator.clear();
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.MODULES_INITIALIZED" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}

	public function getApplicationContext() : IApplicationContext
	{
		return this._applicationContext;
	}

	public function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		constructorVO.shouldAssign 	= id != null;
		
		var type = constructorVO.className;
		var buildMethod : FactoryVOTypeDef->Dynamic = null;
		
		if ( this._factoryMap.exists( type ) )
		{
			buildMethod = this._factoryMap.get( type );
		}
		else if( constructorVO.ref != null )
		{
			buildMethod = hex.compiletime.factory.ReferenceFactory.build;
		}
		else
		{
			buildMethod = hex.compiletime.factory.ClassInstanceFactory.build;
		}
		
		var result = buildMethod( this._getFactoryVO( constructorVO ) );

		if ( id != null )
		{
			_buildVO( constructorVO, id, result );
		}

		return result;
	}
	
	function _buildVO( constructorVO : ConstructorVO, id : String, result : Any ) : Void
	{
		this._tryToRegisterModule( constructorVO );
		this._parseInjectInto( constructorVO );
		this._parseMapTypes( constructorVO );

		this._expressions.push( macro @:mergeBlock { $result;  coreFactory.register( $v { id }, $i { id } ); } );
		this._coreFactory.register( id, result );
	}
	
	function _tryToRegisterModule( constructorVO : ConstructorVO ) : Void
	{
		if ( MacroUtil.implementsInterface( this._getClassType( constructorVO.className ), _moduleInterface ) )
		{
			this._moduleLocator.register( constructorVO.ID, constructorVO.ID );
		}
	}
	
	function _parseInjectInto( constructorVO : ConstructorVO ) : Void
	{
		if ( constructorVO.injectInto && MacroUtil.implementsInterface( this._getClassType( constructorVO.className ), _injectorContainerInterface ) )
		{
			//TODO throws an error if interface is not implemented
			this._injectedInto.push( 
				macro 	@:pos( constructorVO.filePosition )
						@:mergeBlock
						{ 
							__applicationContextInjector.injectInto( $i{ constructorVO.ID } ); 
						}
			);
		}
	}
	
	function _parseMapTypes( constructorVO : ConstructorVO ) : Void
	{
		if ( constructorVO.mapTypes != null )
		{
			var mapTypes = constructorVO.mapTypes;
			for ( mapType in mapTypes )
			{
				//Check if class exists
				FactoryUtil.checkTypeParamsExist( mapType, constructorVO.filePosition );
				
				//Remove whitespaces
				mapType = mapType.split( ' ' ).join( '' );
				
				//Map it
				this._mappedTypes.push( 
					macro 	@:pos( constructorVO.filePosition ) 
							@:mergeBlock 
							{
								__applicationContextInjector.mapClassNameToValue
								( $v{ mapType }, $i{ constructorVO.ID }, $v{ constructorVO.ID } 
								);
							}
				);
			}
		}
	}
	
	inline function _getFactoryVO( constructorVO : ConstructorVO = null ) : FactoryVOTypeDef
	{
		return { constructorVO : constructorVO, contextFactory : this };
	}
	
	//helper
	inline function _getClassType( className : String ) : haxe.macro.Type.ClassType
	{
		try
		{
			return switch Context.getType( className ) 
			{
				case TInst( t, _ ): t.get();
				default: null;
			}
		}
		catch ( e : Dynamic )
		{
			return null;
		}
	}
}
#end