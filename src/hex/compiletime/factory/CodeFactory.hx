package hex.compiletime.factory;

#if macro
import haxe.macro.*;

/**
 * ...
 * @author Francis Bourre
 */
class CodeFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO = factoryVO.constructorVO;
		var e = constructorVO.arguments.shift();
		var args = ArgumentFactory.build( factoryVO, constructorVO.arguments );
		
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		
		constructorVO.type = try
		{
			hex.util.MacroUtil.getFQCNFromComplexType( TypeTools.toComplexType( Context.typeof( e ) ) );
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