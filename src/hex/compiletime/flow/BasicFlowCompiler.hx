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
#end

/**
 * ...
 * @author Francis Bourre
 */
class BasicFlowCompiler 
{
	#if macro
	static function _readFile( fileName : String, ?preprocessingVariables : Expr, ?applicationAssemblerExpr : Expr ) : ExprOf<IApplicationAssembler>
	{
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables );
		
		var assembler 					= new CompileTimeApplicationAssembler( applicationAssemblerExpr );
		var parser 						= new CompileTimeParser( new hex.compiletime.flow.parser.ParserCollection() );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new FlowAssemblingExceptionReporter() );
		parser.parse( assembler, document, CompileTimeContextFactory, CompileTimeApplicationContext );
		
		return assembler.getMainExpression();
	}
	#end

	macro public static function compile( fileName : String, ?preprocessingVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return BasicFlowCompiler._readFile( fileName, preprocessingVariables );
	}
	
	macro public static function compileWithAssembler( assemblerExpr : Expr, fileName : String, ?preprocessingVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return BasicFlowCompiler._readFile( fileName, preprocessingVariables, assemblerExpr );
	}
}