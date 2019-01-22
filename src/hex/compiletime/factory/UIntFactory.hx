package hex.compiletime.factory;

#if macro
import haxe.macro.*;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class UIntFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var result 	: UInt 		= 0;
		
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		
		if ( args != null && args.length > 0 ) 
		{
			result = Std.parseInt( Std.string( args[ 0 ] ) );
		}
		else
		{
			Context.error( "Invalid arguments.", constructorVO.filePosition );
		}

		if ( "" + result != args[ 0 ] && result >= 0 )
		{
			Context.error( "Value is not a UInt", constructorVO.filePosition );
		}

		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $v{ result }:
			macro @:pos( constructorVO.filePosition ) $v{ result };	
	}
}
#end