package hex.compiletime.error;

import haxe.macro.Expr.Position;

/**
 * @author Francis Bourre
 */
interface IExceptionReporter<T> 
{
	function report( message : String, ?position : Position ) : Void;
}