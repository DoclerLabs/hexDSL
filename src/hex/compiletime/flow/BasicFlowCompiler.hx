package hex.compiletime.flow;

import hex.core.IApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.compiletime.CompileTimeParser;
import hex.compiletime.basic.CompileTimeApplicationContext;
import hex.compiletime.basic.CompileTimeContextFactory;
import hex.compiletime.flow.DSLReader;
import hex.compiletime.flow.FlowAssemblingExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.log.MacroLoggerContext;
import hex.log.LogManager;
import hex.preprocess.ConditionalVariablesChecker;
import hex.preprocess.MacroConditionalVariablesProcessor;
#end

/**
 * ...
 * @author Francis Bourre
 */
class BasicFlowCompiler 
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
		var parser 						= new CompileTimeParser( new hex.compiletime.flow.parser.ParserCollection() );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new FlowAssemblingExceptionReporter() );
		parser.parse( assembler, document, CompileTimeContextFactory, CompileTimeApplicationContext, applicationContextName );
		
		return assembler.getMainExpression();
	}
	#end

	macro public static function compile( 	fileName 				: String, 
											?applicationContextName : String,
											?preprocessingVariables : Expr, 
											?conditionalVariables 	: Expr ) : ExprOf<IApplicationAssembler>
	{
		return BasicFlowCompiler._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables );
	}
	
	macro public static function compileWithAssembler( 	assemblerExpr 			: Expr, 
														fileName 				: String,
														?applicationContextName : String,
														?preprocessingVariables : Expr, 
														?conditionalVariables 	: Expr ) : ExprOf<IApplicationAssembler>
	{
		return BasicFlowCompiler._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
}