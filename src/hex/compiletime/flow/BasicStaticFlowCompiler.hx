package hex.compiletime.flow;

import hex.core.IApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.compiletime.CompileTimeParser;
import hex.compiletime.ICompileTimeApplicationAssembler;
import hex.compiletime.basic.CompileTimeApplicationContext;
import hex.compiletime.basic.StaticCompileTimeContextFactory;
import hex.compiletime.flow.AbstractExprParser;
import hex.compiletime.flow.DSLReader;
import hex.compiletime.flow.FlowAssemblingExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.compiletime.util.ContextBuilder;
import hex.core.VariableExpression;
import hex.log.LogManager;
import hex.log.MacroLoggerContext;
import hex.parser.AbstractParserCollection;
import hex.preprocess.ConditionalVariablesChecker;
import hex.preprocess.flow.MacroConditionalVariablesProcessor;
import hex.util.MacroUtil;

using Lambda;
using hex.util.LambdaUtil;
using tink.MacroApi;
#end

/**
 * ...
 * @author Francis Bourre
 */
class BasicStaticFlowCompiler 
{
	#if macro
	public static var ParserCollectionConstructor : VariableExpression
					->String
					->hex.preprocess.RuntimeParam
					->AbstractParserCollection<AbstractExprParser<hex.compiletime.basic.BuildRequest>>
					= ParserCollection.new;
					
	@:allow( hex.compiletime.flow.parser )
	public static function _readFile(	fileName 						: String,
										?applicationContextName 		: String,
										?preprocessingVariables 		: Expr,
										?conditionalVariables 			: Expr,
										?applicationAssemblerExpression : Expr ) : Expr
	{
		LogManager.context 				= new MacroLoggerContext();
		
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
	
		var assembler 					= new CompileTimeApplicationAssembler();
		var assemblerExpression			= { name: '', expression: applicationAssemblerExpression };
		var parser 						= new CompileTimeParser( ParserCollectionConstructor( assemblerExpression, fileName, reader.getRuntimeParam() ) );

		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new FlowAssemblingExceptionReporter() );
		parser.parse( assembler, document, StaticCompileTimeContextFactory, CompileTimeApplicationContext, applicationContextName );

		return assembler.getMainExpression();
	}
	#end

	macro public static function compile( 	assemblerExpr 			: Expr, 
											fileName 				: String,
											?applicationContextName : String,
											?preprocessingVariables : Expr, 
											?conditionalVariables 	: Expr ) : Expr
	{
		if ( applicationContextName != null && !hex.core.ApplicationContextUtil.isValidName( applicationContextName ) ) 
		{
			haxe.macro.Context.error( 'Invalid application context name.\n Name should be alphanumeric (underscore is allowed).\n First chararcter should not be a number.', haxe.macro.Context.currentPos() );
		}
		
		return BasicStaticFlowCompiler._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
	
	macro public static function extend<T>( assemblerExpr 			: Expr, 
											context 				: ExprOf<T>, 
											fileName 				: String, 
											?preprocessingVariables : Expr, 
											?conditionalVariables 	: Expr ) : ExprOf<T>
	{
		var contextName = BasicStaticFlowCompiler._getContextName( context );
		return BasicStaticFlowCompiler._readFile( fileName, contextName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
	
	#if macro
	static function _getContextName( context )
	{
		var ident = switch( context.expr ) 
		{ 
			case EConst( CIdent( s ) ): "" + s; 
			case _: ""; 
		}
		var localVar = haxe.macro.Context.getLocalVars().get( ident );

		var interfaceName = switch ( localVar )
		{
			case TInst( a, b ):
				Std.string( a ).split( '.' ).pop();
				
			case _:
				null;
		}
		
		return ContextBuilder.getApplicationContextName( interfaceName );
	}
	#end
}

#if macro
class ParserCollection extends AbstractParserCollection<AbstractExprParser<hex.compiletime.basic.BuildRequest>>
{
	var _assemblerExpression 	: VariableExpression;
	var _fileName 				: String;
	var _runtimeParam 			: hex.preprocess.RuntimeParam;
	
	public function new( assemblerExpression : VariableExpression, fileName : String, runtimeParam : hex.preprocess.RuntimeParam ) 
	{
		this._assemblerExpression 	= assemblerExpression;
		this._fileName 				= fileName;
		this._runtimeParam 			= runtimeParam;
		
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new StaticContextParser( this._assemblerExpression ) );
		this._parserCollection.push( new hex.compiletime.flow.parser.RuntimeParameterParser( this._runtimeParam ) );
		this._parserCollection.push( new hex.compiletime.flow.parser.ImportContextParser( hex.compiletime.flow.parser.FlowExpressionParser.parser ) );
		this._parserCollection.push( new hex.compiletime.flow.parser.ObjectParser( hex.compiletime.flow.parser.FlowExpressionParser.parser, this._runtimeParam ) );
		this._parserCollection.push( new Launcher( this._assemblerExpression, this._fileName, this._runtimeParam ) );
	}
}

class StaticContextParser extends AbstractExprParser<hex.compiletime.basic.BuildRequest>
{
	var _assemblerVariable 	: VariableExpression;

	public function new( assemblerVariable : VariableExpression ) 
	{
		super();
		this._assemblerVariable = assemblerVariable;
	}
	
	override public function parse() : Void
	{
		//Register
		this._applicationContextClass.name = this._applicationContextClass.name != null ? this._applicationContextClass.name : Type.getClassName( hex.runtime.basic.ApplicationContext );
		ContextBuilder.register( this._applicationAssembler.getFactory( this._factoryClass, this.getApplicationContext() ), this._applicationContextClass.name );
		
		//Create runtime applicationAssembler
		if ( this._assemblerVariable.expression == null )
		{
			var applicationAssemblerTypePath = MacroUtil.getTypePath( "hex.runtime.ApplicationAssembler" );
			this._assemblerVariable.expression = macro new $applicationAssemblerTypePath();
		}
		
		//Create runtime applicationContext
		var applicationContextClass = null;
		try
		{
			applicationContextClass = MacroUtil.getPack( this._applicationContextClass.name );
		}
		catch ( error : Dynamic )
		{
			this._exceptionReporter.report( "Type not found '" + this._applicationContextClass.name + "' ", this._applicationContextClass.pos );
		}
		
		//Add expression
		var expr = macro @:mergeBlock { var applicationContext = this._applicationAssembler.getApplicationContext( $v { this._applicationContextName }, $p { applicationContextClass } ); };
		( cast this._applicationAssembler ).addExpression( expr );
	}
}

class Launcher extends AbstractExprParser<hex.compiletime.basic.BuildRequest>
{
	var _assemblerVariable 	: VariableExpression;
	var _fileName 			: String;
	var _runtimeParam 		: hex.preprocess.RuntimeParam;
	
	public function new( assemblerVariable : VariableExpression, fileName : String, runtimeParam : hex.preprocess.RuntimeParam ) 
	{
		super();
		
		this._assemblerVariable = assemblerVariable;
		this._fileName 			= fileName;
		this._runtimeParam 		= runtimeParam;
	}
	
	override public function parse() : Void
	{
		var assembler : ICompileTimeApplicationAssembler = cast this._applicationAssembler;
		
		//Dispatch CONTEXT_PARSED message
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.CONTEXT_PARSED" );
//		assembler.addExpression( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );

		//Create applicationcontext injector
		assembler.addExpression( macro @:mergeBlock { var __applicationContextInjector = applicationContext.getInjector(); } );

		//Create runtime coreFactory
		assembler.addExpression( macro @:mergeBlock { var coreFactory = applicationContext.getCoreFactory(); } );

		//build
		assembler.buildEverything();

		//
		var assemblerVarExpression = this._assemblerVariable.expression;
		var factory = assembler.getFactory( this._factoryClass, this.getApplicationContext() );
		var builder = ContextBuilder.getInstance( factory );
		var file 	= ContextBuilder.getInstance( factory ).buildFileExecution( this._fileName, assembler.getMainExpression(), this._runtimeParam );

		var contextName = this._applicationContextName;
		var varType = builder.getType();
	
		var className = builder._iteration.definition.name;
		
		var classExpr;
		
		var applicationContextClassName = this._applicationContextClass.name == null ? 
			Type.getClassName( hex.runtime.basic.ApplicationContext ): 
				this._applicationContextClass.name;
			
		var applicationContextClassPack = MacroUtil.getPack( applicationContextClassName );
		var applicationContextCT		= haxe.macro.TypeTools.toComplexType( haxe.macro.Context.getType( applicationContextClassName ) );
		
		classExpr = macro class $className { @:keep public function new( assembler )
		{
			this.locator 				= hex.compiletime.CodeLocator.get( $v { contextName }, assembler );
			this.applicationAssembler 	= assembler;
			this.applicationContext 	= this.locator.$contextName;
		}};


		classExpr.pack = [ "hex", "context" ];
		
		classExpr.fields.push(
		{
			name: 'locator',
			pos: haxe.macro.Context.currentPos(),
			kind: FVar( varType ),
			access: [ APublic ]
		});
		
		classExpr.fields.push(
		{
			name: 'applicationAssembler',
			pos: haxe.macro.Context.currentPos(),
			kind: FVar( macro:hex.core.IApplicationAssembler ),
			access: [ APublic ]
		});
		
		classExpr.fields.push(
		{
			name: 'applicationContext',
			pos: haxe.macro.Context.currentPos(),
			kind: FVar( applicationContextCT ),
			access: [ APublic ]
		});
		
		var locatorArguments = if ( this._runtimeParam.type != null ) [ { name: 'param', type:_runtimeParam.type } ] else [];

		var locatorBody = this._runtimeParam.type != null ?
			macro hex.compiletime.CodeLocator.get( $v { contextName }, applicationAssembler ).$file(param) :
				macro hex.compiletime.CodeLocator.get( $v { contextName }, applicationAssembler ).$file();

		var className = classExpr.pack.join( '.' ) + '.' + classExpr.name;
		var cls = className.asTypePath();
		var cloneBody = macro @:mergeBlock 
		{
			return new $cls( assembler ); 
		};

		classExpr.fields.push(
		{
			name: 'execute',
			pos: haxe.macro.Context.currentPos(),
			kind: FFun( 
			{
				args: locatorArguments,
				ret: macro : Void,
				expr: locatorBody
			}),
			access: [ APublic ]
		});
		
		classExpr.fields.push(
		{
			name: 'clone',
			pos: haxe.macro.Context.currentPos(),
			kind: FFun( 
			{
				args: [{name:'assembler', type:macro:hex.core.IApplicationAssembler}],
				ret: className.asComplexType(),
				expr: cloneBody
			}),
			access: [ APublic ]
		});
		
		haxe.macro.Context.defineType( classExpr );
		var typePath = MacroUtil.getTypePath( className );
		assembler.setMainExpression( macro @:mergeBlock { new $typePath( $assemblerVarExpression ); }  );
	}
}
#end