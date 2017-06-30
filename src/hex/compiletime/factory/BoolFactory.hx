package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Francis Bourre
 */
class BoolFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var result : Bool 		= false;
		
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		
		var value = "";
		if ( args != null && args.length > 0 ) 
		{
			value = args[ 0 ];
		}
		
		if ( value == "true" )
		{
			result = true;
		}
		else if ( value == "false" )
		{
			result = false;
		}
		else
		{
			Context.error( "Value is not a Bool", constructorVO.filePosition );
		}
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $v{ result }:
			macro @:pos( constructorVO.filePosition ) $v{ result };	
	}
}
#end