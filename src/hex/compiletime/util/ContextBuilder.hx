package hex.compiletime.util;

#if macro
import haxe.macro.Expr.TypeDefinition;
import hex.core.IApplicationContext;
import hex.core.HashCodeFactory;
import hex.compiletime.ICompileTimeApplicationAssembler;
import hex.compiletime.util.ContextBuilder;

/**
 * ...
 * @author Francis Bourre
 */
class ContextBuilder 
{
	//Key is applicationContext name
	//Value is latest/updated iteration built for this application context's name
	static var _Iteration 			: Map<String, BuildIteration> = new Map();
	
	//Each application context owner got its own context builder
	static var _Map 				: Map<ApplicationContextOwner, ContextBuilder>;
	
	var _owner 						: ApplicationContextOwner;
	
	public var _iteration 			: BuildIteration;

	function new( owner : ApplicationContextOwner, applicationContextClassName : String ) 
	{
		this._owner = owner;
		this._iteration = ContextBuilder._getContextIteration( owner.getApplicationContext().getName(), applicationContextClassName );
	}
	
	static private function _getContextIteration( applicationContextName : String, applicationContextClassName : String ) : BuildIteration
	{
		var contextIteration;
		
		if ( !ContextBuilder._Iteration.exists( applicationContextName ) )
		{
			var definition = ContextUtil.buildClassDefintion( getIterationName( applicationContextName, 0 ) );
			var iDefinition = ContextUtil.buildInterfaceDefintion( getIterationName( applicationContextName, 0 ) );
			
			//Add a field for applicationContext with the name of the context.
			definition.fields.push( ContextUtil.buildInstanceFieldWithClassName( applicationContextName, applicationContextClassName ) );
			
			contextIteration = { iteration: 0, definition: definition, iDefinition: iDefinition, contextName: applicationContextName, contextClassName: applicationContextClassName, defined: false };
			ContextBuilder._Iteration.set( applicationContextName, contextIteration );
		}
		else
		{
			contextIteration = ContextBuilder._Iteration.get( applicationContextName );
			contextIteration.iteration++;
			var iterationName = getIterationName( applicationContextName, contextIteration.iteration );
			contextIteration.definition = ContextUtil.updateClassDefintion( iterationName, contextIteration.definition );
			contextIteration.iDefinition = ContextUtil.extendInterfaceDefintion( iterationName, contextIteration.iDefinition );
		}

		return contextIteration;
	}
	
	public static function getIterationName( applicationContextName : String, iteration : Int )
	{
		return applicationContextName + '_' + iteration;
	}
	
	public static function getApplicationContextName( interfaceIterationName : String ) : String
	{
		return interfaceIterationName.substring( 0, interfaceIterationName.lastIndexOf( '_' ) );
	}
	
	static public function getInstance( owner : ApplicationContextOwner ) : ContextBuilder
	{
		if ( !ContextBuilder._Map.exists( owner ) )
		{
			haxe.macro.Context.error( 'ContextBuilder not found for this owner.', haxe.macro.Context.currentPos() );
		}
		
		return ContextBuilder._Map.get( owner );
	}
	
	static public function register( owner : ApplicationContextOwner, applicationContextClassName : String ) 
	{
		if ( ContextBuilder._Map == null )
		{
			ContextBuilder._Map = new Map();
			haxe.macro.Context.onAfterTyping( ContextBuilder._onAfterTyping );
		}
		
		ContextBuilder._Map.set( owner, new ContextBuilder( owner, applicationContextClassName ) );
	}
	
	//Each instance of the DSL is reprezented by a class property
	// The name of the property is the context ID.
	public function addFieldWithClassName( fieldName : String, className : String ) : Void
	{
		var field = ContextUtil.buildInstanceFieldWithClassName( fieldName, className );
		this._iteration.definition.fields.push( field );
	}
	
	public function addField( fieldName : String, ct : haxe.macro.Expr.ComplexType ) : Void
	{
		var field = ContextUtil.buildInstanceField( fieldName, ct );
		this._iteration.definition.fields.push( field );
	}
	
	public function instantiate()
	{
		return ContextUtil.instantiateContextDefinition( this._iteration.definition );
	}
	
	//For each DSL building iteration we add a new method that encapsulates all the building process
	public function buildFileExecution( fileName : String, e : haxe.macro.Expr, runtimeParam : hex.preprocess.RuntimeParam ) : String
	{
		var methodName = 'm_' + haxe.crypto.Md5.encode( fileName );
		var contextExecution = ContextUtil.buildFileExecution( methodName, e, runtimeParam.type );
		this._iteration.definition.fields.push( contextExecution.field );
		return methodName;
	}
	
	//This method return interface related to current DSL building iteration.
	//This interface extends the previous one tied to previous DSL building iteration.
	public function getType() : Null<haxe.macro.Expr.ComplexType>
	{
		var interfaceExpr = this._iteration.iDefinition;
		
		for ( field in this._iteration.definition.fields )
		{
			if ( field.name != 'new' )
			{
				switch( field.kind )
				{
					case FVar( t, e ):
						interfaceExpr.fields.push( { name: field.name, kind: FVar( t, e ), pos:haxe.macro.Context.currentPos(), access: [ APublic ] } );
						
					case FFun( f ):
						interfaceExpr.fields.push( { name: field.name, meta: [ { name: ":noCompletion", params: [], pos: haxe.macro.Context.currentPos() } ], kind: FFun( {args: f.args, ret:macro:Void, expr:null, params:f.params} ), pos:haxe.macro.Context.currentPos(), access: [ APublic ] } );

					case _:
						haxe.macro.Context.error( 'field not handled here', haxe.macro.Context.currentPos() );
				}
				
			}
		}
		
		interfaceExpr.isExtern = false;
		haxe.macro.Context.defineType( interfaceExpr );

		haxe.macro.TypeTools.getClass( haxe.macro.Context.getType( 'hex.context.' + interfaceExpr.name ) ).fields.get();
		return haxe.macro.TypeTools.toComplexType( haxe.macro.Context.getType( 'hex.context.' + interfaceExpr.name ) );
	}
	
	//Build final class for each different context name
	static function _onAfterTyping( types : Array<haxe.macro.Type.ModuleType> ) : Void
	{
		var iti = ContextBuilder._Iteration.keys();
		while ( iti.hasNext() )
		{
			var contextName = iti.next();
			var contextIteration = ContextBuilder._Iteration.get( contextName );
	
			if ( !contextIteration.defined )
			{
				contextIteration.defined = true;
				var td = ContextUtil.makeFinalClassDefintion( contextName, contextIteration.definition, contextIteration.contextClassName );
				haxe.macro.Context.defineType( td );
			}
		}
	}
	
	public static function forceGeneration( contextName : String ) : Void
	{
		var contextIteration = ContextBuilder._Iteration.get( contextName );
		if ( !contextIteration.defined )
		{
			contextIteration.defined = true;
			var td = ContextUtil.makeFinalClassDefintion( contextName, contextIteration.definition, contextIteration.contextClassName );
			haxe.macro.Context.defineType( td );
		}
	}
}

typedef BuildIteration =
{
	var iteration 			: Int;
	var definition 			: TypeDefinition;
	var iDefinition 		: TypeDefinition;
	var contextName 		: String;
	var contextClassName 	: String;
	var defined				: Bool;
}

typedef ApplicationContextOwner =
{
	function getApplicationContext() : IApplicationContext;
}
#end