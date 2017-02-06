package hex.compiletime.factory;

#if macro
import haxe.macro.Expr;
import hex.error.PrivateConstructorException;
import hex.vo.FactoryVODef;

/**
 * ...
 * @author Francis Bourre
 */
class ReferenceFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
	
	static public function build<T:FactoryVODef>( factoryVO : T ) : Expr
	{
		var result : Expr 	= null;
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;
		var key 			= constructorVO.ref;
		var coreFactory		= factoryVO.contextFactory.getCoreFactory();

		if ( key.indexOf( "." ) != -1 )
		{
			key = Std.string( ( key.split( "." ) ).shift() );
		}

		if ( !( coreFactory.isRegisteredWithKey( key ) ) )
		{
			factoryVO.contextFactory.buildObject( key );
		}
		
		if ( constructorVO.ref.indexOf( "." ) != -1 )
		{
			result = macro @:pos( constructorVO.filePosition ) $p { constructorVO.ref.split( '.' ) };
		}
		else 
		{
			result = macro @:pos( constructorVO.filePosition ) $i{ key };
		}
		
		//Building result
		return constructorVO.shouldAssign ?
			macro var $idVar = $v{ result }:
			macro $result;
	}
}
#end