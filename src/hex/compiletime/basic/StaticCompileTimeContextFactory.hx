package hex.compiletime.basic;

#if macro
import hex.compiletime.basic.vo.FactoryVOTypeDef;
import hex.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class StaticCompileTimeContextFactory extends CompileTimeContextFactory
{
	override function _buildVO( constructorVO : ConstructorVO, id : String, result : Any ) : Void
	{
		this._tryToRegisterModule( constructorVO );
		this._parseInjectInto( constructorVO );
		this._parseMapTypes( constructorVO );
		
		if ( constructorVO.cType != null )
		{
			hex.compiletime.util.ContextBuilder.getInstance( this ).addField( id, constructorVO.cType );
		}
		else
		{
			hex.compiletime.util.ContextBuilder.getInstance( this ).addFieldWithClassName( id, constructorVO.type );
		}

		this._expressions.push( macro @:mergeBlock { $result;  coreFactory.register( $v { id }, $i { id } ); this.$id = $i { id }; } );
		this._coreFactory.register( id, result );
	}
}
#end