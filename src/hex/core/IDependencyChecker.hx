package hex.core;

/**
 * @author Francis Bourre
 */
interface IDependencyChecker
{
    function registerDependency( vo: {ID: String, filePosition: haxe.macro.Expr.Position, arguments: Array<Dynamic>} ) : Void;
}