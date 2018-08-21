package hex.compiletime.factory;

#if macro
import haxe.macro.*;

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
		
		var e = if ( arg != null )
		{
			constructorVO.arguments = [ arg ];
			var eArg = ArgumentFactory.build( factoryVO,  constructorVO.arguments )[ 0 ];
			macro @:pos(constructorVO.filePosition) var fx = function() { var code = $expr; code.execute($eArg); return code.locator; };
		}
		else
		{
			macro @:pos(constructorVO.filePosition) var fx = function() { var code = $expr; code.execute(); return code.locator; };
		}
		
		constructorVO.type = className;
		return macro @:mergeBlock @:pos( constructorVO.filePosition ) {  $e; var $idVar = cast fx(); };
	}
}
#end