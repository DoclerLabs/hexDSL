package hex.compiletime.factory;

#if macro
import haxe.macro.*;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ClosureFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static inline function _bindFactory( ref, args ) return macro $ref .bind( $a { args } );
	static inline function _blankType( vo ) { vo.cType = tink.macro.Positions.makeBlankType( vo.filePosition ); return MacroUtil.getFQCNFromComplexType( vo.cType ); }
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var vo 				= factoryVO.constructorVO;
		var pos 			= vo.filePosition;
		var id 				= vo.ID;
		var args 			= ArgumentFactory.build( factoryVO );
		
		//We temporary remove the assignment, we want to proceeed it later
		var shouldAssign = vo.shouldAssign;
		vo.shouldAssign = false;
		var ref = ReferenceFactory.build( factoryVO );
		//We put back the assignment request
		vo.shouldAssign = shouldAssign;
		
		var e = _bindFactory( ref, args );
		vo.type = vo.abstractType != null ? vo.abstractType : try MacroUtil.getFQCNFromExpression( e ) catch ( e : Dynamic ) _blankType( vo );
		var result = ClassInstanceFactory.getResult( e, id, vo );
		
		return macro @:pos(pos) $result;
	}
}
#end