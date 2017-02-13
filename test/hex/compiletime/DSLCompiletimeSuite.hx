package hex.compiletime;

import hex.compiletime.flow.ApplicationContextBuildingTest;
import hex.compiletime.flow.BasicFlowCompilerTest;
import hex.compiletime.xml.BasicXmlCompilerTest;

/**
 * ...
 * @author Francis Bourre
 */
class DSLCompiletimeSuite
{
	@Suite( "Compiletime" )
    public var list : Array<Class<Dynamic>> = [ ApplicationContextBuildingTest, BasicFlowCompilerTest, BasicXmlCompilerTest ];
}