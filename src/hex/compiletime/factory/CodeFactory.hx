package hex.compiletime.factory;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.compiletime.basic.vo.FactoryVOTypeDef;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class CodeFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO = factoryVO.constructorVO;
		var e = constructorVO.arguments.shift();
		var args = ArgumentFactory.build( factoryVO );
		
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		
		constructorVO.type = try
		{
			MacroUtil.getFQCNFromComplexType( TypeTools.toComplexType( Context.typeof( e ) ) );
		}
		catch ( e: Dynamic )
		{
			"Dynamic";
		}

		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $e:
			macro @:pos( constructorVO.filePosition ) $e;	
	}
}
#end