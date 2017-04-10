package hex.compiletime.flow;

import hex.core.IApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiletime.ICompileTimeApplicationAssembler;
import hex.compiletime.flow.AbstractExprParser;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.compiletime.CompileTimeParser;
import hex.compiletime.basic.CompileTimeApplicationContext;
import hex.compiletime.basic.StrictCompileTimeContextFactory;
import hex.compiletime.flow.DSLReader;
import hex.compiletime.flow.FlowAssemblingExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.compiletime.util.ContextBuilder;
import hex.log.MacroLoggerContext;
import hex.log.LogManager;
import hex.parser.AbstractParserCollection;
import hex.preprocess.ConditionalVariablesChecker;
import hex.preprocess.MacroConditionalVariablesProcessor;
import hex.util.MacroUtil;
#end

/**
 * ...
 * @author Francis Bourre
 */
class StrictFlowCompiler 
{
	#if macro
	static function _readFile(	fileName 					: String, 
								?applicationContextName 	: String,
								?preprocessingVariables 	: Expr, 
								?conditionalVariables 		: Expr, 
								?applicationAssemblerExpr 	: Expr ) : ExprOf<IApplicationAssembler>
	{
		LogManager.context 				= new MacroLoggerContext();
		
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
		
		var assembler 					= new CompileTimeApplicationAssembler( applicationAssemblerExpr );
		var parser 						= new CompileTimeParser( new ParserCollection( fileName ) );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new FlowAssemblingExceptionReporter() );
		parser.parse( assembler, document, StrictCompileTimeContextFactory, CompileTimeApplicationContext, applicationContextName );
		
		return assembler.getMainExpression();
	}
	#end

	macro public static function compile( 	fileName 				: String, 
											?applicationContextName : String,
											?preprocessingVariables : Expr, 
											?conditionalVariables 	: Expr ) : ExprOf<IApplicationAssembler>
	{
		return StrictFlowCompiler._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables );
	}
	
	macro public static function compileWithAssembler( 	assemblerExpr 			: Expr, 
														fileName 				: String,
														?applicationContextName : String,
														?preprocessingVariables : Expr, 
														?conditionalVariables 	: Expr ) : ExprOf<IApplicationAssembler>
	{
		return StrictFlowCompiler._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
}

#if macro
class ParserCollection extends AbstractParserCollection<AbstractExprParser<hex.compiletime.basic.BuildRequest>>
{
	var _fileName : String;
	
	public function new( fileName : String ) 
	{
		this._fileName = fileName;
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new hex.compiletime.flow.parser.ApplicationContextParser() );
		this._parserCollection.push( new hex.compiletime.flow.parser.ObjectParser() );
		this._parserCollection.push( new Launcher( this._fileName ) );
	}
}

class Launcher extends AbstractExprParser<hex.compiletime.basic.BuildRequest>
{
	var _fileName : String;
	
	public function new( fileName : String ) 
	{
		super();
		this._fileName = fileName;
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

		//
		var factory = assembler.getFactory( this._factoryClass, this.getApplicationContext() );
		var builder = ContextBuilder.getInstance( factory );
		var file 	= ContextBuilder.getInstance( factory ).buildFileExecution( this._fileName, assembler.getMainExpression() );
		
		var contextName = this._applicationContextName;
		//cast locator
		//var ee = macro @:mergeBlock { var cls = Type.resolveClass('hex.context.' + $v{contextName}); var locator = Type.createInstance( cls, [] ); };
		
		
		//return program
		//var instance = builder.instantiate();
		//assembler.setMainExpression( macro @:mergeBlock { var locator = $instance; locator.$file(); locator; }  );
		
		var varType = builder.getType();
		var ee = macro @:mergeBlock { var locator : $varType = hex.compiletime.ContextLocator.getContext( $v{contextName} ); };
		assembler.setMainExpression( macro @:mergeBlock { $ee; locator.$file(); locator; }  );
	}
}
#end