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
	public static function buildClassDefintion( id : String ) : TypeDefinition
	{
		var className = id;
		var classExpr = macro class $className{ public function new(){} };
		classExpr.pack = [ "hex", "context" ];
		return classExpr;
	}
	
	/**
	 * Update previous class container and returns a cloned new one.
	 * @param	String ID used to generate the new class name
	 * @param	TypeDefinition Previous class to copy definition from
	 * @return TypeDefinition
	 */
	public static function updateClassDefintion( id : String, previous : TypeDefinition ) : TypeDefinition
	{
		var className = id;
		var classExpr = macro class $className{ public function new(){} };
		
		var fields =  previous.fields;
		for ( field in fields )
		{
			if ( field.name != 'new' )
			{
				classExpr.fields.push( field );
			}
		}
		
		classExpr.pack = [ "hex", "context" ];
		return classExpr;
	}
	
	/**
	 * Build empty interface container for context representation.
	 * @param	String ID used to generate interface name
	 * @return 	TypeDefinition
	 */
	public static function buildInterfaceDefintion( id : String ) : TypeDefinition
	{
		var interfaceName = 'I' + id;
		var interfaceExpr = macro interface $interfaceName{};
		interfaceExpr.pack = [ "hex", "context" ];
		return interfaceExpr;
	}
	
	/**
	 * Extend previous interface container and returns a new one.
	 * @param	String id used to generate new interface name
	 * @param	TypeDefinition Previous class to copy definition from and to extend
	 * @return TypeDefinition
	 */
	public static function extendInterfaceDefintion( id : String, previous : TypeDefinition ) : TypeDefinition
	{
		var tp = MacroUtil.getTypePath( 'hex.context.' + previous.name );
		var interfaceName = 'I' + id;
		var interfaceExpr = macro interface $interfaceName extends $tp{};
		interfaceExpr.pack = [ "hex", "context" ];
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
		
		var interfaceName 				= 'I' + previous.name;
		var tp 							= MacroUtil.getTypePath( 'hex.context.I' + previous.name );
		var assemblerCT 				= macro:hex.core.IApplicationAssembler;
		var applicationContextCT		= TypeTools.toComplexType( Context.getType( applicationContextClassName ) );
		var applicationContextClassPack = MacroUtil.getPack( applicationContextClassName );
		
		var classExpr = macro class $className implements $tp { public function new( applicationAssembler : $assemblerCT ) 
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
		
		classExpr.pack = [ "hex", "context" ];
		return classExpr;
	}
	
	/**
	 * Build a public class property
	 * @param	instanceID 	Context ID that will become property's name
	 * @param	typeName	Type of the context ID that will become property's type
	 * @return 	class property as Field
	 */
	public static function buildInstanceFieldWithClassName( instanceID : String, typeName : String ) : Field
	{
		var newField : Field = 
		{
			name: instanceID,
			pos: Context.currentPos(),
			kind: null,
			access: [ APublic ]
		}
		
		newField.kind = FVar( switch ( typeName.split('<')[0] )
		{
			case "Array": 	
				typeName.indexOf( '<' ) != -1 ?
					TypeTools.toComplexType( Context.typeof( Context.parseInlineString( "new " + typeName + "()", Context.currentPos() ) ) ):
					macro:Array<Dynamic>;
					
			case "null" | "Object": macro:Dynamic;
			case _: 				MacroUtil.getComplexTypeFromString( typeName );
		} );
		
		return newField;
	}
	
	public static function buildInstanceField( instanceID : String, ct : ComplexType ) : Field
	{
		return
		{
			name: instanceID,
			pos: Context.currentPos(),
			kind: FVar( ct ),
			access: [ APublic ]
		}
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