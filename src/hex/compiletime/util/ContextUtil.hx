package hex.compiletime.util;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.TypeTools;
import hex.compiletime.util.ContextExecution;
import hex.error.PrivateConstructorException;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
@:final 
class ContextUtil 
{

	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }

	public static function instantiateContextDefinition( definition : TypeDefinition ) : Expr
	{
		Context.defineType( definition );
		var typePath = MacroUtil.getTypePath( definition.pack.join( '.' ) + '.' + definition.name );
		return { expr: MacroUtil.instantiate( typePath ), pos: Context.currentPos() };
	}
	
	/**
	 * Build class container  context with class representation.
	 * @param	applicationAssembler ID
	 * @param	applicationContext name
	 * @return TypeDefinition
	 */
	public static function buildContextDefintion( assemblerID : String, contextName : String ) : TypeDefinition
	{
		var className = "Context_" + contextName + "_WithAssembler_" + assemblerID;
		var classExpr = macro class $className
		{ 
			public function new()
			{}
		};
		
		classExpr.pack = [ "hex", "compiletime", "util" ];
		return classExpr;
	}
	
	/**
	 * Build a public class property
	 * @param	name of the property
	 * @param	type of the property
	 * @return class property as Field
	 */
	public static function buildInstanceField( instanceID : String, instanceClassName : String ) : Field
	{
		var newField : Field = 
		{
			name: instanceID,
			pos: Context.currentPos(),
			kind: null,
			access: [ APublic ]
		}
		
		var type = Context.getType( instanceClassName );
		var complexType = TypeTools.toComplexType( type );
		newField.kind = FVar( complexType );
		
		return newField;
	}
	
	/**
	 * Make a virtual applicationContext through class representation.
	 * Each property will reference a defined ID.
	 * @param	applicationContext's name
	 * @return ContextExecution
	 */
	public static function buildContextExecution( fileName : String ) : ContextExecution
	{
		var newField : Field = 
		{
			name: fileName,
			pos: Context.currentPos(),
			kind: null,
			access: [ APublic ]
		}
		
		var ret : ComplexType 			= null;
		var args : Array<FunctionArg> 	= [];
		
		var body = 
		macro 
		{
			trace( $v{ fileName } );
		};
							
		newField.kind = FFun( 
			{
				args: args,
				ret: ret,
				expr: body
			}
		);
		
		return { field: newField, body: body, fileName: fileName };
	}
	
	public static function appendContextExecution( contextExecution : ContextExecution, expr : Expr ) : Void
	{
		var e = contextExecution.body;
		
		switch( e.expr )
		{
			case EBlock( exprs ):
				exprs.push( expr );
				
			case _:
				
		}
	}
}
#end