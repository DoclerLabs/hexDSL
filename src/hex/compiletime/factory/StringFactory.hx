package hex.compiletime.factory;

#if macro
using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class StringFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : haxe.macro.Expr
	{
		var result : String 	= null;
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;

		if ( args != null && args.length > 0 && args[ 0 ] != null )
		{
			result = Std.string( args[ 0 ] );
		}
		else
		{
			haxe.macro.Context.error( "String instance cannot returns an empty String.", constructorVO.filePosition );
		}

		if ( result == null )
		{
			result = "";
			#if debug
			haxe.macro.Context.warning( "String instance cannot returns an empty String.", constructorVO.filePosition );
			#end
		}

		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $v{ result }:
			macro @:pos( constructorVO.filePosition ) $v{ result };	
	}
}
#end