package hex.compiletime.factory;
import haxe.macro.Context;
import haxe.macro.Printer;
import hex.core.ContextTypeList;

using hex.error.Error;

#if macro
/**
 * ...
 * @author Francis Bourre
 */
class ReferenceFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
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
			var fields = Context.parseInlineString( constructorVO.ref/*.split( '.' )*/, constructorVO.filePosition );
			
			if ( constructorVO.instanceCall == null )
			{
				result = fields;
			}
			else
			{
				if ( constructorVO.type == ContextTypeList.INSTANCE )
				{
					var methodName = constructorVO.instanceCall;
					constructorVO.cType = tink.macro.Positions.makeBlankType( constructorVO.filePosition );
					
					return return constructorVO.shouldAssign ?
						macro @:pos( constructorVO.filePosition ) var $idVar =  $fields .$methodName( $a { ArgumentFactory.build( factoryVO,  constructorVO.arguments ) } ):
						macro @:pos( constructorVO.filePosition ) $fields .$methodName( $a { ArgumentFactory.build( factoryVO,  constructorVO.arguments ) } );
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
					return constructorVO.shouldAssign ?
						macro @:pos( constructorVO.filePosition ) var $idVar = $i { key } .$methodName( $a { ArgumentFactory.build( factoryVO, constructorVO.arguments) } ):
						macro @:pos( constructorVO.filePosition ) $i { key } .$methodName( $a { ArgumentFactory.build( factoryVO, constructorVO.arguments ) } );
				}
				else if ( constructorVO.type == ContextTypeList.CLOSURE_FACTORY )
				{
					return constructorVO.shouldAssign ?
						macro @:pos( constructorVO.filePosition ) var $idVar = $i {methodName}( $a { ArgumentFactory.build( factoryVO, constructorVO.arguments ) } ):
						macro @:pos( constructorVO.filePosition ) $i {methodName}( $a { ArgumentFactory.build( factoryVO, constructorVO.arguments ) } );
				}
			}
		}
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $v{ result }:
			macro @:pos( constructorVO.filePosition ) $result;
	}
}
#end