package hex.compiletime.factory;
import hex.compiletime.flow.BasicStaticFlowCompiler;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Francis Bourre
 */
class ContextFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		
		var desc : { className: String, expr: Expr, arg: hex.vo.ConstructorVO } = cast constructorVO.arguments[0];
		
		var className 	=  desc.className;
		var expr 		= desc.expr;
		var arg 		= desc.arg;
		
		constructorVO.arguments = [ arg ];
		var eArg = ArgumentFactory.build( factoryVO )[ 0 ];
		constructorVO.type = className;
		
		var e = macro var fx = function() { var code = $expr; code.execute($eArg); return code.locator; };
		return macro @:mergeBlock @:pos( constructorVO.filePosition ) {  $e; var $idVar = cast fx(); };
	}
}
#end