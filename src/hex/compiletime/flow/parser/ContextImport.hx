package hex.compiletime.flow.parser;

import hex.vo.ConstructorVO;

/**
 * @author Francis Bourre
 */
typedef ContextImport =
{
	id 			: String,
	isPublic	: Bool,
	fileName 	: String,
	arg			: ConstructorVO,
	pos 		: haxe.macro.Expr.Position
}