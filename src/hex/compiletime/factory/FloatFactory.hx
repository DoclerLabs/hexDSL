package hex.compiletime.factory;

#if macro
import haxe.macro.*;

/**
 * ...
 * @author Francis Bourre
 */
class FloatFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var result : Float 		= Math.NaN;
		
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		
		if ( args != null && args.length > 0 ) 
		{
			result = Std.parseFloat( args[ 0 ] );
		}

		if ( Math.isNaN( result ) || "" + result != args[ 0 ] )
		{
			Context.error( "Value is not a Float", constructorVO.filePosition );
		}
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $v{ result }:
			macro @:pos( constructorVO.filePosition ) $v{ result };	
	}
}
#end