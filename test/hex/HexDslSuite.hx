package hex;

import hex.compiletime.DSLCompiletimeSuite;
import hex.core.CoreSuite;
import hex.runtime.DSLRuntimeSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexDslSuite
{
	@Suite( "HexDsl suite" )
    public var list : Array<Class<Dynamic>> = [ DSLCompiletimeSuite, CoreSuite, DSLRuntimeSuite ];
}