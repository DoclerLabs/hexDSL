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
		
		var type = 
		if ( constructorVO.abstractType != null ) 	ContextFactoryUtil.getComplexType( constructorVO.abstractType, constructorVO.filePosition );
			else if ( constructorVO.cType != null ) constructorVO.cType;
				else 								ContextFactoryUtil.getComplexType( constructorVO.type, constructorVO.filePosition );

		hex.compiletime.util.ContextBuilder.getInstance( this )
			.addField( id, type, constructorVO.filePosition, (constructorVO.lazy?result:null) );

		if ( !constructorVO.lazy )
		{
			this._expressions.push( macro @:mergeBlock { $result;  coreFactory.register( $v { id }, $i { id } ); this.$id = $i { id }; } );
		}
		
		this._coreFactory.register( id, result );
	}
}
#end