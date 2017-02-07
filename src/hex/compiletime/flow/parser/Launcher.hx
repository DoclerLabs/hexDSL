package hex.compiletime.flow.parser;

#if macro
import hex.compiletime.ICompileTimeApplicationAssembler;
import hex.compiletime.flow.AbstractExprParser;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class Launcher extends AbstractExprParser<hex.compiletime.basic.BuildRequest>
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		var assembler : ICompileTimeApplicationAssembler = cast this._applicationAssembler;
		
		//Dispatch CONTEXT_PARSED message
		var messageType = MacroUtil.getStaticVariable( "hex.ioc.assembler.ApplicationAssemblerMessage.CONTEXT_PARSED" );
		assembler.addExpression( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );

		//Create applicationcontext injector
		assembler.addExpression( macro @:mergeBlock { var __applicationContextInjector = applicationContext.getInjector(); } );

		//Create runtime coreFactory
		assembler.addExpression( macro @:mergeBlock { var coreFactory = applicationContext.getCoreFactory(); } );

		//build
		assembler.buildEverything();
		
		//return program
		assembler.addExpression( assembler.getAssemblerExpression() );
	}
}
#end