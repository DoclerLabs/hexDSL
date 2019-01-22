package hex.compiletime.basic;


#if macro
import haxe.macro.*;
import hex.util.MacroUtil;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class ContextFactoryUtil 
{
	/** @private */ function new() throw new PrivateConstructorException();
	
	static public function getComplexType( className : String, pos : haxe.macro.Expr.Position )
	{
		return switch ( className.split('<')[0] )
		{
			case "Array": 	
				className.indexOf( '<' ) != -1 ?
					TypeTools.toComplexType( Context.typeof( Context.parseInlineString( "new " + className + "()", pos ) ) ):
					macro:Array<Dynamic>;
					
			case "null" | "Object": macro:Dynamic;
			case _: 				MacroUtil.getComplexTypeFromString( className );
		}
	}
}
#end