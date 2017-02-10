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
import hex.ioc.assembler.ConditionalVariablesChecker;
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
	static function _readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr, ?applicationAssemblerExpr : Expr ) : ExprOf<IApplicationAssembler>
	{
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var dslReader					= new DSLReader();
		var document 					= dslReader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
		
		var assembler 					= new CompileTimeApplicationAssembler( applicationAssemblerExpr );
		var parser 						= new CompileTimeParser( new hex.compiletime.xml.parser.ParserCollection() );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new ExceptionReporter( dslReader.positionTracker ) );
		parser.parse( assembler, document, CompileTimeContextFactory, CompileTimeApplicationContext );

		return assembler.getMainExpression();
	}
	#end
	
	macro public static function compile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return BasicXmlCompiler._readXmlFile( fileName, preprocessingVariables, conditionalVariables );
	}
	
	macro public static function compileWithAssembler( assemblerExpr : Expr, fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return BasicXmlCompiler._readXmlFile( fileName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
}
