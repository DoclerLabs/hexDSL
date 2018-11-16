package hex.compiletime.factory;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class BoolOpFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();

	static inline function _blankType( vo ) { vo.cType = tink.macro.Positions.makeBlankType( vo.filePosition ); return MacroUtil.getFQCNFromComplexType( vo.cType ); }

	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;
		var args 			= constructorVO.arguments;
		var e 				= constructorVO.arguments.shift();

		var builtArgs = ( constructorVO.arguments.length > 0 ) ? ArgumentFactory.build( factoryVO, constructorVO.arguments ) : [];
		builtArgs.shift();
		builtArgs.shift();
		setVO( builtArgs, constructorVO, factoryVO.contextFactory.getTypeLocator() );

		//Building result
		var t = constructorVO.cType;
		return constructorVO.shouldAssign && !constructorVO.lazy ?
			macro @:pos( constructorVO.filePosition ) var $idVar : $t = $e:
			macro @:pos( constructorVO.filePosition ) $e;	
	}

	static function setVO( builtArgs : Array<Expr>, constructorVO : hex.vo.ConstructorVO, typelocator : hex.collection.ILocator<String, String> )
	{
		var ids = builtArgs.map(
			function ( el )
				return switch( el.expr )
				{
					case EConst(CIdent(ident)): TypeTools.toComplexType(haxe.macro.Context.getType(typelocator.locate(ident)));
					case _: TypeTools.toComplexType( Context.typeof(el));
				}
		).map( function( el ) return macro (null:$el) );

		if( ids.length >  0 ) 
			constructorVO.cType = TypeTools.toComplexType(haxe.macro.Context.typeof(macro $a{ids}[0])); 
				else _blankType( constructorVO );

		constructorVO.type = constructorVO.fqcn = hex.util.MacroUtil.getFQCNFromComplexType( constructorVO.cType );
	}
}
#end