package hex.compiletime.factory;

#if macro
import haxe.macro.Expr;
import hex.vo.ConstructorVO;
import hex.compiletime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class ArgumentFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Array<Expr>
	{
		var result 			= [];
		var factory 		= factoryVO.contextFactory;
		var constructorVO 	= factoryVO.constructorVO;
		
		for ( arg in constructorVO.arguments )
			result.push( factory.buildVO( arg ) );

		return result;
	}
}
#end