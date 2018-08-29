package hex.compiletime.factory;

#if macro
import haxe.macro.*;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ExpressionFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static inline function _varType( type, position ) return TypeTools.toComplexType( Context.typeof( Context.parseInlineString( '( null : ${type})', position ) ) );
	static inline function _blankType( vo ) { vo.cType = tink.macro.Positions.makeBlankType( vo.filePosition ); return MacroUtil.getFQCNFromComplexType( vo.cType ); }
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO = factoryVO.constructorVO;
		var e = constructorVO.arguments.shift();
		var args = ArgumentFactory.build( factoryVO, constructorVO.arguments );
		
		var idVar 				= constructorVO.ID;
		var args 				= constructorVO.arguments;
		
		constructorVO.type = constructorVO.abstractType != null ? constructorVO.abstractType : try
		{
			hex.util.MacroUtil.getFQCNFromComplexType( TypeTools.toComplexType( Context.typeof( e ) ) );
		}
		catch ( e: Dynamic )
		{
			//We cannot predict the type
			_blankType( constructorVO );
			
		}

		//Used only if the result is not lazy and should be assigned
		var t = constructorVO.cType = constructorVO.cType != null ? constructorVO.cType : _varType( constructorVO.type, constructorVO.filePosition ); 

		//Building result
		return constructorVO.shouldAssign && !constructorVO.lazy ?
			macro @:pos( constructorVO.filePosition ) var $idVar : $t = $e:
			macro @:pos( constructorVO.filePosition ) $e;	
	}
}
#end