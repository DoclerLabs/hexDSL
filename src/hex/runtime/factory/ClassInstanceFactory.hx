package hex.runtime.factory;

import hex.error.PrivateConstructorException;
import hex.runtime.basic.vo.FactoryVOTypeDef;
import hex.runtime.factory.ArgumentFactory;
import hex.runtime.factory.ReferenceFactory;

/**
 * ...
 * @author Francis Bourre
 */
class ClassInstanceFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }

	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Dynamic
	{
		var result : Dynamic 	= null;
		var constructorVO 		= factoryVO.constructorVO;
		var coreFactory			= factoryVO.contextFactory.getCoreFactory();

		if ( constructorVO.ref != null )
		{
			result = ReferenceFactory.build( factoryVO );
		}
		else
		{
			//build arguments
			constructorVO.arguments = ArgumentFactory.build( factoryVO );
			
			//TODO Allows proxy classes
			/*if ( !coreFactory.hasProxyFactoryMethod( constructorVO.className ) )
			{
				var classReference = ClassUtil.getClassReference( constructorVO.className );
			
				var isModule : Bool = ClassUtil.classExtendsOrImplements( classReference, IModule );
				if ( isModule && constructorVO.ID != null && constructorVO.ID.length > 0 )
				{
					var moduleDomain = DomainUtil.getDomain( constructorVO.ID, Domain );
					DomainExpert.getInstance().registerDomain( moduleDomain );
					AnnotationProvider.registerToParentDomain( moduleDomain, factoryVO.contextFactory.getApplicationContext().getDomain() );
				}
			}*/
			
			result = coreFactory.buildInstance( constructorVO );
		}
		
		return result;
	}
}