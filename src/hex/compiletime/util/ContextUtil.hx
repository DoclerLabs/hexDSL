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
	 * Build empty class container for context representation.
	 * @param 	String ID used to generate class name
	 * @return 	TypeDefinition
	 */
	public static function buildClassDefintion( className : String, pack : Array<String> ) : TypeDefinition
	{
		var className = className;
		var classExpr = macro class $className{ public function new(){} };
		classExpr.pack = pack;
		return classExpr;
	}
	
	/**
	 * Update previous class container and returns a cloned new one.
	 * @param	String ID used to generate the new class name
	 * @param	TypeDefinition Previous class to copy definition from
	 * @return TypeDefinition
	 */
	public static function updateClassDefintion( className : String, previous : TypeDefinition ) : TypeDefinition
	{
		var classExpr = macro class $className{ public function new(){} };
		
		var fields =  previous.fields;
		for ( field in fields )
		{
			if ( field.name != 'new' )
			{
				classExpr.fields.push( field );
			}
		}
		
		classExpr.pack = previous.pack;
		return classExpr;
	}
	
	/**
	 * Build empty interface container for context representation.
	 * @param	String ID used to generate interface name
	 * @return 	TypeDefinition
	 */
	public static function buildInterfaceDefintion( interfaceName : String, pack : Array<String> ) : TypeDefinition
	{
		var name = 'I' + interfaceName;
		var interfaceExpr = macro interface $name{};
		interfaceExpr.pack = pack;
		return interfaceExpr;
	}
	
	/**
	 * Extend previous interface container and returns a new one.
	 * @param	String id used to generate new interface name
	 * @param	TypeDefinition Previous class to copy definition from and to extend
	 * @return TypeDefinition
	 */
	public static function extendInterfaceDefintion( interfaceName : String, previous : TypeDefinition ) : TypeDefinition
	{
		var tp = MacroUtil.getTypePath( previous.pack.join('.') + '.' + previous.name );
		var name = 'I' + interfaceName;
		var interfaceExpr = macro interface $name extends $tp{};
		interfaceExpr.pack = previous.pack;
		return interfaceExpr;
	}
	
	/**
	 * Make final class for context representation. This class will merge
	 * all the informations found in different DSL building iterations.
	 * @param	String Application context name used to generate the final class name
	 * @param	TypeDefinition Previous class to copy definition from.
	 * @return TypeDefinition
	 */
	public static function makeFinalClassDefintion( id : String, previous : TypeDefinition, applicationContextClassName : String ) : TypeDefinition
	{
		var className 					= id;
		
		var name 						= 'I' + previous.name;
		var tp 							= MacroUtil.getTypePath( previous.pack.join('.') + '.' + name );
		var assemblerCT 				= macro:hex.core.IApplicationAssembler;
		var applicationContextCT		= TypeTools.toComplexType( Context.getType( applicationContextClassName ) );
		var applicationContextClassPack = MacroUtil.getPack( applicationContextClassName );
		
		var classExpr = macro class $className implements $tp { @:keep public function new( applicationAssembler : $assemblerCT ) 
		{ 
			this._applicationAssembler = applicationAssembler;
			this.$className = _applicationAssembler.getApplicationContext( $v{className}, $p{applicationContextClassPack} );
		} };
		
		var fields =  previous.fields;
		
		fields.push(
		{
			name: '_applicationAssembler',
			meta: [ { name: ":noCompletion", params: [], pos: haxe.macro.Context.currentPos() } ],
			pos: haxe.macro.Context.currentPos(),
			kind: FVar( assemblerCT ),
			access: [ APublic ]
		});
		
		for ( field in fields )
		{
			if ( field.name != 'new' )
			{
				classExpr.fields.push( field );
			}
		}
		
		classExpr.pack = previous.pack;
		return classExpr;
	}

	public static function buildField( instanceID : String, ct : ComplexType, pos : haxe.macro.Expr.Position, lazy : Bool, isPublic : Bool = true ) : Field
	{
		return !lazy ?
		{
			name: instanceID,
			pos: pos,
			kind: FVar( ct ),
			access: isPublic ? [ APublic ] : [ APrivate ]
		}
		:
		{
			name: instanceID,
			pos: pos,
			kind: FProp( 'get', 'null', ct ),
			access: isPublic ? [ APublic ] : [ APrivate ]
		}
	}
	
	public static function buildLazyField( instanceID : String, ct : ComplexType, body : Expr, pos : haxe.macro.Expr.Position, isPublic : Bool = true ) : Field
	{
		var lazyField : Field = 
		{
			name: 'get_' + instanceID,
			meta: [ { name: ":noCompletion", params: [], pos: pos } ],
			pos: pos,
			kind: null,
			access: isPublic ? [ APublic ] : [ APrivate ]
		}

		lazyField.kind = FFun( 
			{
				args: [],
				ret: ct,
				expr: body
			}
		);
		
		return lazyField;
	}
	
	/**
	 * Make a virtual applicationContext building inside method's body.
	 * Each main file (with inclusions) got its own method.
	 * Each property will reference a defined ID.
	 * @param	file's name
	 * @return ContextExecution
	 */
	public static function buildFileExecution( fileName : String, body : Expr, ?paramType : Null<ComplexType> ) : ContextExecution
	{
		var newField : Field = 
		{
			name: fileName,
			meta: [ { name: ":noCompletion", params: [], pos: Context.currentPos() } ],
			pos: Context.currentPos(),
			kind: null,
			access: [ APublic ]
		}
		
		var ret : ComplexType 			= macro : Void;
		var args : Array<FunctionArg> 	= paramType != null ? [ { name: 'param', type: paramType, opt: false } ] : [];
							
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