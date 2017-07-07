package hex.compiletime.factory;

#if macro
import haxe.macro.*;

/**
 * ...
 * @author Francis Bourre
 */
class XmlFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var result : Expr 	= null;
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;
		var args 			= constructorVO.arguments;
		var factory			= constructorVO.factory;

		if ( args != null ||  args.length > 0 )
		{
			//TODO simplify
			var source : String = args[ 0 ];
			
			if ( source.length > 0 )
			{
				if ( factory == null )
				{
					result = macro @:pos( constructorVO.filePosition ) Xml.parse( $v { source } ); 
				}
				else
				{
					var typePath 	= hex.util.MacroUtil.getTypePath( factory, constructorVO.filePosition );
					
					//Assign right type description
					var xmlContent = macro Xml.parse( $v { source } );
					constructorVO.type = hex.util.MacroUtil.getFQCNFromExpression( macro ( new $typePath() ).parse( $xmlContent ) );

					result = macro 	@:pos( constructorVO.filePosition ) 
									( new $typePath() ).parse( $xmlContent );
				}
			}
			else
			{
				#if debug
				Context.warning( "Empty XML.", constructorVO.filePosition );
				#end
				
				result = macro Xml.parse( '' );
			}
		}
		else
		{
			#if debug
			Context.warning( "Empty XML.", constructorVO.filePosition );
			#end

			result = macro Xml.parse( '' );
		}
		
		//Building result
		return constructorVO.shouldAssign ?
			macro @:pos( constructorVO.filePosition ) var $idVar = $result:	
			macro @:pos( constructorVO.filePosition ) $result;
	}
}
#end