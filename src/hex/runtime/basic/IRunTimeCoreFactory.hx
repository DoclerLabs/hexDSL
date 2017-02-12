package hex.runtime.basic;

import hex.core.CoreFactoryVODef;
import hex.core.ICoreFactory;

/**
 * @author Francis Bourre
 */
interface IRunTimeCoreFactory extends ICoreFactory
{
	function buildInstance( constructorVO : CoreFactoryVODef ) : Dynamic;
	function fastEvalFromTarget( target : Dynamic, toEval : String ) : Dynamic;
	function hasProxyFactoryMethod( className : String ) : Bool;
}