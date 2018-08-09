package hex.compiletime.factory;

#if macro
import haxe.macro.*;
import hex.compiletime.flow.parser.ExpressionUtil;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ClosureFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static inline function _bindFactory( ref, args, pos ) return macro @:pos(pos)  $ref .bind( $a { args } );
	static inline function _blankType( vo ) { vo.cType = tink.macro.Positions.makeBlankType( vo.filePosition ); return MacroUtil.getFQCNFromComplexType( vo.cType ); }
	
	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var vo 				= factoryVO.constructorVO;
		var pos 			= vo.filePosition;
		var id 				= vo.ID;
		var args 			= ArgumentFactory.build( factoryVO );
	
		var coreFactory		= factoryVO.contextFactory.getCoreFactory();
		var typelocator		= factoryVO.contextFactory.getTypeLocator();

		//We temporary remove the assignment, we want to proceeed it later
		var shouldAssign = vo.shouldAssign;
		vo.shouldAssign = false;
		var ref = ReferenceFactory.build( factoryVO );
		//We put back the assignment request
		vo.shouldAssign = shouldAssign;

		var e 		= _bindFactory( ref, args, pos );
		var refID 	= ExpressionUtil.compressField( ref ).split( '.' )[ 0 ];
		
		if ( coreFactory.isRegisteredWithKey( refID ) )
		{//Instance method
			var refExpr = coreFactory.locate( refID );
			var nullExpr = macro null;
			var exprType = _bindFactory( ref, [ for ( el in args ) MacroUtil.getIdent( el ) != '_' ?  nullExpr : el ], pos );
			vo.type = vo.abstractType != null ? vo.abstractType : try MacroUtil.getFQCNFromComplexType(TypeTools.toComplexType( Context.typeof( macro { $refExpr; $exprType; } ))) catch ( e : Dynamic ) _blankType( vo );
			_registerType( typelocator, e, vo.type );
		}
		else
		{//Static method
			var nullExpr = macro null;
			var exprType = _bindFactory( ref, [ for ( el in args ) MacroUtil.getIdent( el ) != '_' ?  nullExpr : el ], pos );
			vo.type = vo.abstractType != null ? vo.abstractType : try MacroUtil.getFQCNFromComplexType(TypeTools.toComplexType( Context.typeof( macro { $exprType; } ))) catch ( e : Dynamic ) _blankType( vo );
			_registerType( typelocator, e, vo.type );
		}
		
		//Final result
		var result = ClassInstanceFactory.getResult( e, id, vo );
		return macro @:pos(pos) $result;
	}
	
	inline static function _registerType( typelocator, e, type ) : Void
	{
		var key = new Printer().printExpr( e );
		if ( !typelocator.isRegisteredWithKey( key ) ) typelocator.register( key, type );
	}
}
#end