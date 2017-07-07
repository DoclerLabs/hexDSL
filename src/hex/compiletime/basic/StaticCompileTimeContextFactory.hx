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

		if ( constructorVO.abstractType != null )
		{
			hex.compiletime.util.ContextBuilder.getInstance( this ).addField( id, ContextFactoryUtil.getComplexType( constructorVO.abstractType, constructorVO.filePosition ), constructorVO.filePosition, (constructorVO.lazy?result:null) );
		}
		else if ( constructorVO.cType != null )
		{
			hex.compiletime.util.ContextBuilder.getInstance( this ).addField( id, constructorVO.cType, constructorVO.filePosition, (constructorVO.lazy?result:null) );
		}
		else
		{
			hex.compiletime.util.ContextBuilder.getInstance( this ).addField( id, ContextFactoryUtil.getComplexType( constructorVO.type, constructorVO.filePosition ), constructorVO.filePosition, (constructorVO.lazy?result:null) );
		}

		if ( !constructorVO.lazy )
		{
			this._expressions.push( macro @:mergeBlock { $result;  coreFactory.register( $v { id }, $i { id } ); this.$id = $i { id }; } );
		}
		
		this._coreFactory.register( id, result );
	}
}
#end