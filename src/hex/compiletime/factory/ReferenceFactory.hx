package hex.compiletime.factory;
import haxe.macro.Printer;
import hex.core.ContextTypeList;

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
			if ( constructorVO.instanceCall == null )
			{
				result = macro @:pos( constructorVO.filePosition ) $p { constructorVO.ref.split( '.' ) };
			}
			else
			{
				if ( constructorVO.type == ContextTypeList.INSTANCE )
				{
					var methodName = constructorVO.instanceCall;
					constructorVO.cType = tink.macro.Positions.makeBlankType( constructorVO.filePosition );
					return macro @:pos( constructorVO.filePosition ) var $idVar =  $p { constructorVO.ref.split( '.' ) } .$methodName( $a { ArgumentFactory.build( factoryVO ) } );
				}
			}
		}
		else 
		{
			if ( constructorVO.instanceCall == null )
			{
				result = macro @:pos( constructorVO.filePosition ) $i { key };
			}
			else
			{
				var methodName = constructorVO.instanceCall;
				constructorVO.cType = tink.macro.Positions.makeBlankType( constructorVO.filePosition );
				if ( constructorVO.type == ContextTypeList.INSTANCE )
				{
					return macro @:pos( constructorVO.filePosition ) var $idVar = $i { key } .$methodName( $a { ArgumentFactory.build( factoryVO ) } );
				}
				else if ( constructorVO.type == ContextTypeList.CLOSURE_FACTORY )
				{
					return macro @:pos( constructorVO.filePosition ) var $idVar = $i {methodName}( $a { ArgumentFactory.build( factoryVO ) } );
				}
			}
		}
		
		//Building result
		return constructorVO.shouldAssign ?
			macro var $idVar = $v{ result }:
			macro $result;
	}
}
#end