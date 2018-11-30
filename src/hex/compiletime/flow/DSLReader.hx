package hex.compiletime.flow;

#if macro
import hex.compiletime.DSLData;
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.preprocess.ConditionalVariablesChecker;
import hex.preprocess.KeywordPreprocessor;
import hex.preprocess.MacroPreprocessor;
import hex.preprocess.RuntimeParametersPreprocessor;
import hex.compiletime.flow.parser.ExpressionUtil;

/**
 * ...
 * @author Francis Bourre
 */
class DSLReader 
{
	var _runtimeParamsProcessor = new RuntimeParametersPreprocessor();
	
	public function new() {}

	public function read( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariablesChecker : ConditionalVariablesChecker )
	{
		var e = this._processFile( null, { fileName: fileName, pos: Context.currentPos() }, preprocessingVariables, conditionalVariablesChecker );
		return e;  
	}
	
	public function getRuntimeParam() : hex.preprocess.RuntimeParam
	{
		return this._runtimeParamsProcessor.param();
	}

	function _processFile( e : Expr, file : Include, ?preprocessingVariables : Expr, ?conditionalVariablesChecker : ConditionalVariablesChecker )
	{
		//read file
		var dsl = this._readFile( file.fileName, file.pos );

		//preprocess
		dsl.data = KeywordPreprocessor.parse( dsl.data );
		dsl.data = MacroPreprocessor.parse( dsl.data, preprocessingVariables );

		//replace runtime parameters with whitespaces
		if ( e == null )
		{
			dsl.data = this._runtimeParamsProcessor.parse( dsl );
		}

		//parse
		var expr = Context.parseInlineString
		( 
			dsl.data, Context.makePosition( { file: dsl.path, min: 0, max: dsl.length } ) 
		);

		if ( e == null )
		{
			e = expr;
		}
		else
		{
			var mainBlock = this._findFirstBlock( e );
			if ( mainBlock != null )
			{
				
				var blockToAdd = this._findFirstBlock( expr );
				if ( blockToAdd != null )
				{
					for ( expToAdd in blockToAdd )
					{
						mainBlock.push( expToAdd );
					}
				}
			}
		}
		
		//parsers
		this._searchForParser( expr );
		
		//include
		var includeList = this._searchForInclude( expr );
		
		for ( includedFile in includeList )
		{
			this._processFile( e, includedFile, preprocessingVariables, conditionalVariablesChecker );
		}
		
		return e;
	}

	function _findFirstBlock( e : Expr ) : Array<Expr>
	{
		switch( e.expr )
		{
			case EBlock( exprs ): 
				return exprs;

			case EMeta( s, expr ):
				return this._findFirstBlock( expr );
				
			case _: 
				Context.error( 'Invalid content', e.pos );
				return null;
		}
	}
	
	function _searchForParser( e : Expr ) : Bool
	{
		var meta = null;
		
		switch( e.expr )
		{
			case EMeta( s, expr ): 
				e = expr;
				meta = s;

			case _: return false;
		}
		
		
		if ( meta.name == 'parser' )
		{
			for ( entry in meta.params )
			{
				switch( entry.expr )
				{
					case EField( e, field ): 
						var parserClassName = ExpressionUtil.compressField( e, field );
						var parserClass = macro $p { parserClassName.split('.') };
						Context.typeExpr( macro @:pos(parserClass.pos) $parserClass.activate() );

					case EConst( CString( id ) ): trace( id );
					case _:
				}
			}
		}
		
		return _searchForParser( e );
	}
	
	function _searchForInclude( e : Expr, includeList : Array<Include> = null ) : Array<Include>
	{
		if ( includeList == null )
		{
			includeList = [];
		}
		
		var meta = null;
		
		switch( e.expr )
		{
			case EMeta( s, expr ): 
				e = expr;
				meta = s;

			case _: return includeList;
		}
		
		if ( meta.name == 'include' )
		{
			for ( entry in meta.params )
			{
				switch( entry.expr )
				{
					case EConst( CString( id ) ): includeList.push( { fileName: id, pos: entry.pos } );
					case _:
				}
			}
		}
		
		return _searchForInclude( e, includeList );
	}
	
	function _readFile( fileName : String, ?pos : Position ) : DSLData
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
		catch ( error : Any )
		{
			return Context.error( 'File loading failed @$fileName $error', pos == null ? Context.currentPos() : pos );
		}
	}
}

typedef Include =
{
	fileName 	: String,
	pos 		: Position
}
#end