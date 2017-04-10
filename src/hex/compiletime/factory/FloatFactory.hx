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
class FloatFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
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
		if ( constructorVO.shouldAssign )
		{
			hex.compiletime.util.ContextBuilder.getInstance( factoryVO.contextFactory )
				.addField( idVar, 'Float' );
			return macro @:pos( constructorVO.filePosition ) var $idVar = $v { result };
		}
		else
		{
			return macro @:pos( constructorVO.filePosition ) $v { result };
		}
	}
}
#end