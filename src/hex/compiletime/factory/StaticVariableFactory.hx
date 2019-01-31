package hex.compiletime.factory;

#if macro

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class StaticVariableFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : haxe.macro.Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		
		//Building result
		var result	= hex.util.MacroUtil.getStaticVariable( constructorVO.staticRef, constructorVO.filePosition );
		
		//Assign right type description
		constructorVO.type = hex.util.MacroUtil.getFQCNFromExpression( result );
		
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $result:
			macro @:pos( constructorVO.filePosition ) $result;
	}
}
#end