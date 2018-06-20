package hex.compiletime.util;

#if macro
import haxe.macro.Expr.Access;
import haxe.macro.Expr.TypeDefinition;
import hex.core.IApplicationContext;
import hex.core.HashCodeFactory;
import hex.compiletime.ICompileTimeApplicationAssembler;
import hex.compiletime.util.ContextBuilder;
using tink.CoreApi;

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
	
	static var _callbacks			: Array<TypeDefinition->Void> = [];
	
	var _owner 						: ApplicationContextOwner;
	
	static var _uniqueID = 0;
	
	
	public var _iteration 			: BuildIteration;

	function new( owner : ApplicationContextOwner, applicationContextClassName : String ) 
	{
		this._owner 	= owner;
		var contextName = owner.getApplicationContext().getName();
		this._iteration = ContextBuilder._getContextIteration( contextName, applicationContextClassName, [ 'hex', 'context' + (ContextBuilder._uniqueID++) ] );
	}
	
	static private function _getContextIteration( applicationContextName : String, applicationContextClassName : String, pack : Array<String> ) : BuildIteration
	{
		var contextIteration;
		
		if ( !ContextBuilder._Iteration.exists( applicationContextName ) )
		{
			var definition = ContextUtil.buildClassDefintion( getIterationName( applicationContextName, 0 ), pack );
			var iDefinition = ContextUtil.buildInterfaceDefintion( getIterationName( applicationContextName, 0 ), pack );
			
			//Add a field for applicationContext with the name of the context.
			definition.fields.push( ContextUtil.buildField( applicationContextName, hex.util.MacroUtil.getComplexTypeFromString( applicationContextClassName ), haxe.macro.Context.currentPos(), false ) );
			
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
	
	static public function onContextTyping( callback ) : Void _callbacks.push( callback );
	
	public function addField( fieldName : String, ct : haxe.macro.Expr.ComplexType, pos : haxe.macro.Expr.Position, lazyExpr : haxe.macro.Expr = null, isPublic : Bool = true ) : Void
	{
		var field = ContextUtil.buildField( fieldName, ct, pos, lazyExpr!=null, isPublic );
		this._iteration.definition.fields.push( field );
	
		if ( lazyExpr != null )
		{
			lazyExpr = macro @:pos( pos )
			{
				if ( this.$fieldName == null )
				{
					this.$fieldName = $lazyExpr;
				}
				return this.$fieldName;
			}
			var lazyField = ContextUtil.buildLazyField( fieldName, ct, lazyExpr, pos, isPublic );
			this._iteration.definition.fields.push( lazyField );
		}
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
			if ( field.name != 'new' && field.access.indexOf( APrivate ) == -1 )
			{
				switch( field.kind )
				{
					case FVar( t, e ):
						interfaceExpr.fields.push( { name: field.name, kind: FVar( t, e ), pos:haxe.macro.Context.currentPos(), access: [ APublic ] } );
						
					case FFun( f ):
						if ( field.name.indexOf('get_') != 0 )
							interfaceExpr.fields.push( { name: field.name, meta: [ { name: ":noCompletion", params: [], pos: haxe.macro.Context.currentPos() }, { name: ":keep", params: [], pos: haxe.macro.Context.currentPos() } ], kind: FFun( {args: f.args, ret:f.ret, expr:null, params:f.params} ), pos:haxe.macro.Context.currentPos(), access: [ APublic ] } );

					case FProp( get, set, t, e ):
						interfaceExpr.fields.push( { name: field.name, kind: FProp( get, set, t ), pos:haxe.macro.Context.currentPos(), access: [ APublic ] } );
						
					case _:
						haxe.macro.Context.error( 'field not handled here', haxe.macro.Context.currentPos() );
				}
			}
		}
		
		interfaceExpr.isExtern = false;
		haxe.macro.Context.defineType( interfaceExpr );

		var interfaceFQN = interfaceExpr.pack.join('.') + '.' + interfaceExpr.name;
		haxe.macro.TypeTools.getClass( haxe.macro.Context.getType( interfaceFQN ) ).fields.get();
		return haxe.macro.TypeTools.toComplexType( haxe.macro.Context.getType( interfaceFQN ) );
	}
	
	static var allDefined = Signal.trigger();
	static public function afterContextsDefined(cb:Callback<Noise>)
		return allDefined.handle(cb);
	
	//Build final class for each different context name
	static function _onAfterTyping( types : Array<haxe.macro.Type.ModuleType> ) : Void
	{
		var iti = ContextBuilder._Iteration.keys();
		var anyDefined = false;
		while ( iti.hasNext() )
		{
			var contextName = iti.next();
			var contextIteration = ContextBuilder._Iteration.get( contextName );
	
			if ( !contextIteration.defined )
			{
				anyDefined = contextIteration.defined = true;
				var td = ContextUtil.makeFinalClassDefintion( contextName, contextIteration.definition, contextIteration.contextClassName );
				haxe.macro.Context.defineType( td );
				
				//broadcast
				for ( callback in _callbacks ) callback( td );
			}
		}
		if (!anyDefined) allDefined.trigger(Noise);
	}
	
	public static function forceGeneration( contextName : String ) : Void
	{
		var contextIteration = ContextBuilder._Iteration.get( contextName );
		if ( !contextIteration.defined )
		{
			contextIteration.defined = true;
			var td = ContextUtil.makeFinalClassDefintion( contextName, contextIteration.definition, contextIteration.contextClassName );
			haxe.macro.Context.defineType( td );
			
			//broadcast
			for ( callback in _callbacks ) callback( td );
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
