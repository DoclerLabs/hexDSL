package hex.compiletime.flow.parser;

#if macro
import hex.compiletime.flow.AbstractExprParser;
import hex.runtime.basic.ApplicationContext;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextParser extends AbstractExprParser<hex.compiletime.basic.BuildRequest>
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		//Create runtime applicationContext
		var assemblerExpr	= ( cast this._applicationAssembler ).getAssemblerExpression();
		
		var applicationContextClass = null;
		if ( this._applicationContextClass.name != null )
		{
			try
			{
				applicationContextClass = MacroUtil.getPack( this._applicationContextClass.name );
			}
			catch ( error : Dynamic )
			{
				this._exceptionReporter.report( "Type not found '" + this._applicationContextClass.name + "' ", this._applicationContextClass.pos );
			}
		}
		else
		{
			applicationContextClass = MacroUtil.getPack( Type.getClassName( ApplicationContext ) );
		}
	
		var expr = macro @:mergeBlock { var applicationContext = $assemblerExpr.getApplicationContext( $v { this._applicationContextName }, $p { applicationContextClass } ); };
		( cast this._applicationAssembler ).addExpression( expr );
	}
}
#end