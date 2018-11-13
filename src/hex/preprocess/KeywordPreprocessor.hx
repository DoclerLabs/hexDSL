package hex.preprocess;

import haxe.macro.Expr;

/**
 * ...
 * @author Francis Bourre
 */
class KeywordPreprocessor
{
    function new(){}

    #if macro
    static public function parse( data : String ) : String
	{
		data = ~/(\bif\b)(\s*)(\()+/g.map
		(
			data,
			function ( ereg ) return '_if('
		);

		return data;
	}
    #end
}