package hex.compiletime.factory;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import hex.util.MacroUtil;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class BoolOpFactory
{
	/** @private */ function new() throw new PrivateConstructorException();

	static inline function _blankType( vo ) { vo.cType = tink.macro.Positions.makeBlankType( vo.filePosition ); return MacroUtil.getFQCNFromComplexType( vo.cType ); }

	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;
		var e 				= constructorVO.arguments.shift();

		ArgumentFactory.build( factoryVO, constructorVO.arguments );

		//Building result
		constructorVO.cType = macro :Bool;
		constructorVO.type = constructorVO.fqcn = 'Bool';

		var t = constructorVO.cType;
		return constructorVO.shouldAssign && !constructorVO.lazy ?
			macro @:pos( constructorVO.filePosition ) var $idVar : $t = $e:
			macro @:pos( constructorVO.filePosition ) $e;	
	}
}
#end