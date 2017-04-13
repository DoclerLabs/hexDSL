package hex.compiletime;

#if macro
import haxe.macro.Expr;
import hex.core.HashCodeFactory;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeApplicationAssembler implements ICompileTimeApplicationAssembler
{
	var _mApplicationContext 	= new Map<String, IApplicationContext>();
	var _mContextFactories 		= new Map<IApplicationContext, IBuilder<Dynamic>>();
	var _expressions 			= [ macro { } ];
	
	var _assemblerExpression : Expr;

	public function new(){}
	
	public function getFactory<T>( factoryClass: Class<IBuilder<T>>, applicationContext : IApplicationContext ) : IBuilder<T>
	{
		var contextFactory : IBuilder<T> = null;
		
		if ( this._mContextFactories.exists( applicationContext ) )
		{
			contextFactory = cast this._mContextFactories.get( applicationContext );
		}
		else
		{
			contextFactory = Type.createInstance( factoryClass, [ this._expressions ] );
			contextFactory.init( applicationContext );
			this._mContextFactories.set( applicationContext, contextFactory );
		}
			
		return contextFactory;
	}
	
	public function buildEverything() : Void
	{
		var itFactory = this._mContextFactories.iterator();
		var contextFactories = [ while ( itFactory.hasNext() ) itFactory.next() ];
		contextFactories.map( function( factory ) { factory.finalize(); } );
	}
	
	public function release() : Void
	{
		var itFactory = this._mContextFactories.iterator();
		while ( itFactory.hasNext() ) itFactory.next().dispose();
		
		this._mApplicationContext = new Map();
		this._mContextFactories = new Map();
		this._expressions = [ macro {} ];
	}

	public function getApplicationContext<T:IApplicationContext>( applicationContextName : String, applicationContextClass : Class<T> ) : T
	{
		var applicationContext : T;

		if ( this._mApplicationContext.exists( applicationContextName ) )
		{
			applicationContext = cast this._mApplicationContext.get( applicationContextName );

		} else
		{
			applicationContext = Type.createInstance( applicationContextClass, [ applicationContextName ] );
			this._mApplicationContext.set( applicationContextName, applicationContext );
		}

		return applicationContext;
	}
	
	public function addExpression( expr : Expr ) : Void
	{
		this._expressions.push( expr );
	}
	
	public function getMainExpression() : Expr
	{
		return return macro $b{ this._expressions };
	}
	
	public function setMainExpression( e : Expr ) : Void
	{
		this._expressions = [ e ];
	}
}
#end