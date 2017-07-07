package hex.compiletime.factory;

#if macro
/**
 * ...
 * @author Francis Bourre
 */
class ReferenceFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : haxe.macro.Expr
	{
		var result 			= null;
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;
		var key 			= constructorVO.ref;
		var coreFactory		= factoryVO.contextFactory.getCoreFactory();

		if ( key.indexOf( "." ) != -1 )
		{
			key = Std.string( ( key.split( "." ) ).shift() );
		}
		
		if ( key == "this" )
		{
			key = factoryVO.contextFactory.getApplicationContext().getName();
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