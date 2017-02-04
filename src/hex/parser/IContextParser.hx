package hex.parser;

import hex.core.IApplicationAssembler;
import hex.core.IApplicationContext;
import hex.core.IBuilder;

/**
 * @author Francis Bourre
 */
interface IContextParser<ContentType> 
{
	function parse() : Void;
	
	function getContextData() : ContentType;

	function setContextData( data : ContentType ) : Void;
	
	function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void;
	
	function setFactoryClass( factoryClass: Class<IBuilder<Dynamic>> ) : Void;
	
	function setApplicationContextDefaultClass( applicationContextDefaultClass : Class<IApplicationContext> ) : Void;
}