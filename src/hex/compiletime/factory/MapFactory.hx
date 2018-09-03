package hex.compiletime.factory;

#if macro
import haxe.macro.*;
/**
 * ...
 * @author Francis Bourre
 */
class MapFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= MapArgumentFactory.build( factoryVO );
		
		var e = Context.parseInlineString( "new " + constructorVO.type + "()", constructorVO.filePosition );
		if ( constructorVO.shouldAssign )
		{
			var varType = TypeTools.toComplexType( Context.typeof( e ) );
			var result 	= macro @:pos( constructorVO.filePosition ) var $idVar : $varType = $e;
			
			if ( args.length == 0 )
			{
				#if debug
				Context.warning( "Empty Map built.", constructorVO.filePosition );
				#end

			} else
			{
				for ( item in args )
				{
					if ( item.key != null )
					{
						var a = [ item.key, item.value ];
						
						//Fill with arguments
						result = macro 	@:pos( constructorVO.filePosition ) 
						@:mergeBlock 
						{
							$result; 
							$i{ idVar }.set( $a{ a } ); 
						};
						
					} else
					{
						#if debug
						Context.warning( "'null' key for '"  + item.value +"' value added.", constructorVO.filePosition );
						#end
					}
				}
			}
			
			return result;
		}
		else
		{
			return macro @:pos( constructorVO.filePosition ) $e;
		}
	}
}
#end