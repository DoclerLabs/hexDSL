package hex.compiletime;

import hex.compiletime.flow.BasicFlowCompilerTest;

/**
 * ...
 * @author Francis Bourre
 */
class CompiletimeSuite
{
	@Suite( "Compiletime" )
    public var list : Array<Class<Dynamic>> = [BasicFlowCompilerTest];
}