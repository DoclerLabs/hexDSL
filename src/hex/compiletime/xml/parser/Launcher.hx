package hex.compiletime.xml.parser;

#if macro
import hex.compiletime.ICompileTimeApplicationAssembler;
import hex.compiletime.xml.AbstractXmlParser;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class Launcher extends AbstractXmlParser<hex.compiletime.basic.BuildRequest>
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		var assembler : ICompileTimeApplicationAssembler = cast this._applicationAssembler;
		
		//Dispatch CONTEXT_PARSED message
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.CONTEXT_PARSED" );
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