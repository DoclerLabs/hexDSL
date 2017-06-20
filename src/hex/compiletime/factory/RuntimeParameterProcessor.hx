package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiletime.basic.IContextFactory;
import hex.vo.PreProcessVO;

/**
 * ...
 * @author Francis Bourre
 */
class RuntimeParameterProcessor
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function process( factory : IContextFactory, vo : PreProcessVO ) : Expr
	{
		factory.getTypeLocator().register( vo.ID, vo.arguments[ 0 ] );
		
		//Building result
		var e = Context.parse( "var " + vo.ID + " = param." + vo.ID, vo.filePosition );
		return macro @:pos( vo.filePosition ) $e;	
	}
}
#end