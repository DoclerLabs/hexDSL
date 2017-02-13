package hex.runtime.basic;

import hex.core.IApplicationContext;
import hex.vo.ConstructorVO;

/**
 * @author Francis Bourre
 */
interface IRunTimeContextFactory
{
	function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic;
	
	function buildObject( id : String ) : Void;
	
	function getApplicationContext() : IApplicationContext;
	
	function getCoreFactory() : IRunTimeCoreFactory;
}