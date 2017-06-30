package hex.compiletime.factory;

#if macro
import haxe.macro.*;

/**
 * ...
 * @author Francis Bourre
 */
class RuntimeParameterProcessor
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	static public function process( factory : hex.compiletime.basic.IContextFactory, vo : hex.vo.PreProcessVO ) : Expr
	{
		factory.getTypeLocator().register( vo.ID, vo.arguments[ 0 ] );
		
		//Building result
		var e = Context.parse( "var " + vo.ID + " = param." + vo.ID, vo.filePosition );
		return macro @:pos( vo.filePosition ) $e;	
	}
}
#end