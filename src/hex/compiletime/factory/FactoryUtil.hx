package hex.compiletime.factory;

#if macro
import haxe.macro.*;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class FactoryUtil 
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function checkTypeParamsExist( typeParams : String, filePosition : haxe.macro.Expr.Position ) : Void
	{
		try
		{
			var prefix = 'var a:';
			var exp = Context.parseInlineString( prefix + typeParams, Context.currentPos() );
			var t = Context.typeof( exp );
		}
		catch( e: Dynamic )
		{
			Context.error( "" + e, filePosition );
		}
	}
}
#end
