package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.compiletime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class DynamicObjectFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar : Dynamic = {}:
			macro @:pos( constructorVO.filePosition ) { };
			
			
		/*
		//Building result
		if ( constructorVO.shouldAssign )
		{
			hex.compiletime.util.ContextBuilder.getInstance( factoryVO.contextFactory )
				.addField( idVar, 'Dynamic' );
			return macro @:pos( constructorVO.filePosition ) var $idVar : Dynamic = {};
		}
		else
		{
			return macro @:pos( constructorVO.filePosition ) {};
		}
		*/
	}
}
#end