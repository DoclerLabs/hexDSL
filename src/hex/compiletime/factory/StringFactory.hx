package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.vo.FactoryVODef;

/**
 * ...
 * @author Francis Bourre
 */
class StringFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	static public function build<T:FactoryVODef>( factoryVO : T ) : Expr
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
			Context.error( "String instance cannot returns an empty String.", constructorVO.filePosition );
		}

		if ( result == null )
		{
			result = "";
			#if debug
			Context.warning( "String instance cannot returns an empty String.", constructorVO.filePosition );
			#end
		}

		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $v{ result }:
			macro @:pos( constructorVO.filePosition ) $v{ result };	
	}
}
#end