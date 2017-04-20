package hex.compiletime;

/**
 * ...
 * @author Francis Bourre
 */
class DSLCompiletimeSuite
{
	@Suite( "Compiletime" )
    public var list : Array<Class<Dynamic>> = 
	[ 
		hex.compiletime.flow.ApplicationContextBuildingTest, 
		hex.compiletime.xml.ApplicationContextBuildingTest, 
		hex.compiletime.flow.BasicFlowCompilerTest, 
		hex.compiletime.flow.BasicStaticFlowCompilerTest, 
		hex.compiletime.xml.BasicStaticXmlCompilerTest,
		hex.compiletime.xml.BasicXmlCompilerTest 
	];
}