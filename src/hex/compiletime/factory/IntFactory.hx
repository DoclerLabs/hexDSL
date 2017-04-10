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
class IntFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var result 	: Int 		= 0;
		
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		

		if ( args != null && args.length > 0 ) 
		{
			var s = Std.string( args[ 0 ] );
			result = Std.parseInt( s );
		}
		else
		{
			Context.error( "Invalid arguments.", constructorVO.filePosition );
		}
		
		//Building result
		if ( constructorVO.shouldAssign )
		{
			hex.compiletime.util.ContextBuilder.getInstance( factoryVO.contextFactory )
				.addField( idVar, 'Int' );
			return macro @:pos( constructorVO.filePosition ) var $idVar = $v { result };
		}
		else
		{
			return macro @:pos( constructorVO.filePosition ) $v { result };
		}
	}
}
#end