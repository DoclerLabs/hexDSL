package hex.runtime.xml.parser;

import hex.runtime.xml.AbstractXMLParser;

/**
 * ...
 * @author Francis Bourre
 */
class AutoBuildLauncher extends AbstractXMLParser<hex.compiletime.basic.BuildRequest>
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		this._applicationAssembler.buildEverything();
	}
}