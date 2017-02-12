package hex.compiletime.basic;

import hex.core.IApplicationContext;
import hex.core.ICoreFactory;
import hex.vo.ConstructorVO;

/**
 * @author Francis Bourre
 */
interface IContextFactory
{
	function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic;
	
	function buildObject( id : String ) : Void;
	
	function getApplicationContext() : IApplicationContext;
	
	function getCoreFactory() : ICoreFactory;
}
