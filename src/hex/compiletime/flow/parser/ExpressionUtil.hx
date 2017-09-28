package hex.compiletime.flow.parser;

#if macro
import haxe.macro.Expr;
import haxe.macro.ExprTools;

/**
 * ...
 * @author Francis Bourre
 */
@:final
class ExpressionUtil 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();

	static public function compressField( e : Expr, ?previousValue : String = "" ) : String
	{
		return switch( e.expr )
		{
			case EField( ee, field ):
				previousValue = previousValue == "" ? field : field + "." + previousValue;
				return compressField( ee, previousValue );
				
			case ECall( _.expr => EField( ee, field ), params ):
				previousValue = previousValue == "" ? field : field + "." + previousValue;
				return compressField( ee, previousValue );
				
			case ECall( _.expr => EConst(CIdent(id)), params ):
				return previousValue == "" ? id : id + "." + previousValue;
				
			case EConst(CIdent(id)):
				return previousValue == "" ? id : id + "." + previousValue;

			default:
				return previousValue;
		}
	}
	
	static public function getFullClassDeclaration( tp : TypePath ) : String
	{
		var className = ExprTools.toString( macro new $tp() );
		return className.split( "new " ).join( '' ).split( '()' ).join( '' );
	}
	
	static public function getIdent( e : Expr ) : String
	{
		return switch( e.expr )
		{
			case EConst(CIdent(value)): value;
			case _: "";
		}
	}
	
	static public function getBool( e : Expr ) : Bool
	{
		return switch( e.expr )
		{
			case EConst(CIdent('true')): true;
			case _: false;
		}
	}
}
#end