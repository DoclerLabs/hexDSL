package hex.compiletime.flow;

#if macro
import hex.compiletime.DSLData;
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.preprocess.MacroPreprocessor;

/**
 * ...
 * @author Francis Bourre
 */
class DSLReader 
{
	public function new() 
	{
		
	}
	
	public function read( fileName : String, ?preprocessingVariables : Expr ) : Expr
	{
		//read file
		var dsl = this._readFile( fileName );
		
		//preprocess
		dsl.data = MacroPreprocessor.parse( dsl.data, preprocessingVariables );

		//parse
		var expr = Context.parseInlineString
		( 
			dsl.data, Context.makePosition( { file: dsl.path, min: 0, max: dsl.length } ) 
		);
		
		return expr;
	}
	
	function _readFile( fileName : String ) : DSLData
	{
		try
		{
			//resolve
			var path = Context.resolvePath( fileName );
			Context.registerModuleDependency( Context.getLocalModule(), path );
			
			//read data
			var data = sys.io.File.getContent( path );
			
			//instantiate result
			var result = 	{ 	
								data: 				data,
								length: 			data.length, 
								path: 				path
							};
			
			return result;
		}
		catch ( error : Dynamic )
		{
			return Context.error( 'File loading failed @$fileName $error', Context.currentPos() );
		}
	}
}
#end