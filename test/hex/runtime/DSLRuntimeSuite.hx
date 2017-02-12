package hex.runtime;

import hex.runtime.factory.DSLFactorySuite;
import hex.runtime.xml.BasicXmlReaderTest;

/**
 * ...
 * @author Francis Bourre
 */
class DSLRuntimeSuite
{
	@Suite( "Runtime" )
    public var list : Array<Class<Dynamic>> = [ BasicXmlReaderTest, DSLFactorySuite ];
}