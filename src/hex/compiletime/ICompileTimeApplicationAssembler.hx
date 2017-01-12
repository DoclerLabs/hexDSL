package hex.compiletime;

import haxe.macro.Expr;
import hex.core.IApplicationAssembler;

/**
 * @author Francis Bourre
 */
interface ICompileTimeApplicationAssembler extends IApplicationAssembler
{
	function addExpression( expr : Expr ) : Void;

	function getMainExpression() : Expr;

	function getAssemblerExpression() : Expr;
}