package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactory
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		var args 				= ArgumentFactory.build( factoryVO, constructorVO.arguments );

		if ( constructorVO.shouldAssign )
		{
			var exp 	= Context.parseInlineString( "new " + constructorVO.type + "()", constructorVO.filePosition );
			var varType = haxe.macro.TypeTools.toComplexType( Context.typeof( exp ) );
			
			if ( varType == null )
			{
				var t = tink.macro.Positions.makeBlankType( constructorVO.filePosition );
				varType = macro :Array<$t>;
			}
			
			var result 	= macro @:pos( constructorVO.filePosition ) var $idVar : $varType = $a{ args };

			return result;
		}
		else
		{
			return macro @:pos( constructorVO.filePosition ) $a{ args };
		}
	}
}
#end
