package hex.core;

/**
 * @author Francis Bourre
 */
interface IDependencyChecker
{
    function registerDependency( vo: hex.vo.ConstructorVO ) : Void;
}