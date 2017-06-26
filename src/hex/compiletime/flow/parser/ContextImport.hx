package hex.compiletime.flow.parser;

/**
 * @author Francis Bourre
 */
typedef ContextImport =
{
	id 			: String,
	fileName 	: String,
	arg			: String,
	pos 		: haxe.macro.Expr.Position
}