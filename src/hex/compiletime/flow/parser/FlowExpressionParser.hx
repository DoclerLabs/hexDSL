package hex.compiletime.flow.parser;

/**
 * ...
 * @author Francis Bourre
 */
#if macro
class FlowExpressionParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	public static var parser = 
	{
		parseProperty: 		hex.compiletime.flow.parser.expr.PropertyParser.parse, 
		parseType: 			hex.compiletime.flow.parser.expr.TypeParser.parse, 
		parseArgument: 		hex.compiletime.flow.parser.expr.ArgumentParser.parse, 
		parseMapArgument:	hex.compiletime.flow.parser.expr.MapArgumentParser.parse,
		
		typeParser:		
		[
			hex.core.ContextTypeList.HASHMAP 			=> hex.compiletime.flow.parser.custom.HashMapParser.parse,
			hex.core.ContextTypeList.MAPPING_CONFIG		=> hex.compiletime.flow.parser.custom.MappingConfigParser.parse,
			hex.core.ContextTypeList.MAPPING_DEFINITION	=> hex.compiletime.flow.parser.custom.MappingParser.parse
		],
		
		buildMethodParser:		
		[
			'mapping' 							=> hex.compiletime.flow.parser.custom.MappingParser.parse,
			'injectInto' 						=> hex.compiletime.flow.parser.custom.InjectIntoParser.parse,
			'mapType' 							=> hex.compiletime.flow.parser.custom.MapTypeParser.parse,
			'xml' 								=> hex.compiletime.flow.parser.custom.XmlParser.parse
		]
	};	
}
#end