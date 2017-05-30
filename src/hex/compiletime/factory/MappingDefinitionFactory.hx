package hex.compiletime.factory;

#if macro
import haxe.macro.Expr;
using hex.util.MacroUtil;
using Lambda;

/**
 * ...
 * @author Francis Bourre
 */
class MappingDefinitionFactory
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();

	static public function build<T:hex.compiletime.basic.vo.FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var constructorVO 		= factoryVO.constructorVO;
		var idVar 				= constructorVO.ID;
		
		var ct = haxe.macro.TypeTools.toComplexType( haxe.macro.Context.getType( "hex.di.mapping.MappingDefinition" ) );
		
		var result = macro @:pos( constructorVO.filePosition ) 
			var $idVar : $ct = { fromType: "", toValue: null, toClass: null, withName: "", asSingleton: false, injectInto: false };
	
		result = constructorVO.arguments.map(
			function ( arg ) return PropertyFactory.build( factoryVO.contextFactory, arg )
		).flatToExpr( result );

		factoryVO.contextFactory.getCoreFactory().register( 'mappingDefinition#' + idVar, 
			constructorVO.arguments.fold( setPropertyValue, {} ) );
		return return macro @:mergeBlock $result;
	}
	
	static function setPropertyValue( p : hex.vo.PropertyVO, o : Dynamic ) : Dynamic
	{
		Reflect.setField( o, p.name, p.value );
		return o;
	}
}
#end