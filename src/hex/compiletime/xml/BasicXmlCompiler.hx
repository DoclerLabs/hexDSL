package hex.compiletime.xml;

import hex.core.IApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.compiletime.CompileTimeParser;
import hex.compiletime.util.ClassImportHelper;
import hex.compiletime.xml.DSLReader;
import hex.compiletime.xml.ExceptionReporter;
import hex.compiletime.basic.CompileTimeApplicationContext;
import hex.compiletime.basic.CompileTimeContextFactory;
import hex.log.LogManager;
import hex.log.MacroLoggerContext;
import hex.preprocess.ConditionalVariablesChecker;
import hex.preprocess.MacroConditionalVariablesProcessor;

using StringTools;
#end

/**
 * ...
 * @author Francis Bourre
 */
class BasicXmlCompiler
{
	#if macro
	static function _readXmlFile( 	fileName 						: String, 
									?applicationContextName 		: String,
									?preprocessingVariables 		: Expr, 
									?conditionalVariables 			: Expr, 
									?applicationAssemblerExpression : Expr ) : ExprOf<IApplicationAssembler>
	{
		LogManager.context = new MacroLoggerContext();
		
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var dslReader					= new DSLReader();
		var document 					= dslReader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
		
		var assembler 					= new CompileTimeApplicationAssembler();
		var assemblerExpression			= { name: '', expression: applicationAssemblerExpression };
		var parser 						= new CompileTimeParser( new hex.compiletime.xml.parser.ParserCollection( assemblerExpression ) );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new ExceptionReporter( dslReader.positionTracker ) );
		parser.parse( assembler, document, CompileTimeContextFactory, CompileTimeApplicationContext, applicationContextName );

		return assembler.getMainExpression();
	}
	#end
	
	macro public static function compile( 	fileName : String, 
											?applicationContextName : String,
											?preprocessingVariables : Expr, 
											?conditionalVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		if ( applicationContextName != null && !hex.core.ApplicationContextUtil.isValidName( applicationContextName ) ) 
		{
			haxe.macro.Context.error( 'Invalid application context name.\n Name should be alphanumeric (underscore is allowed).\n First chararcter should not be a number.', haxe.macro.Context.currentPos() );
		}
		
		return BasicXmlCompiler._readXmlFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables );
	}
	
	macro public static function compileWithAssembler( 	assemblerExpr : Expr, 
														fileName : String, 
														?applicationContextName : String,
														?preprocessingVariables : Expr, 
														?conditionalVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return BasicXmlCompiler._readXmlFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
}
