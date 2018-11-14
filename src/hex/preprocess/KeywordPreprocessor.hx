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
		data = ~/(?<![$&+,:;=?@#|'<>.^*()%!-])(\bif\b)(\s*)(\()+/g.map
		//data = ~/(\bif\b)(\s*)(\()+/g.map
		(
			data, function ( ereg ) return '_if('
		);

		data = ~/(?<![$&+,:;=?@#|'<>.^*()%!-])(\bif\b)(\s*)(\()+/g.map
		//data = ~/(\band\b)(\s*)(\()+/g.map
		(
			data, function ( ereg ) return '_and('
		);

		data = ~/(?<![$&+,:;=?@#|'<>.^*()%!-])(\bif\b)(\s*)(\()+/g.map
		//data = ~/(\bor\b)(\s*)(\()+/g.map
		(
			data, function ( ereg ) return '_or('
		);

		return data;
	}
    #end
}