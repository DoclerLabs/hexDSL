package hex.preprocess;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiletime.DSLData;
import hex.util.MacroUtil;

class RuntimeParametersPreprocessor 
{
	var _dsl 		: DSLData;
	var _param 		: Null<ComplexType>;
	var _initBlock 	: Array<Expr>;
	
	public function new(){}

	public function parse( dsl : DSLData ) : String
	{
		this._dsl 		= dsl;
		this._param 	= null;
		this._initBlock = [];
		
		var result = ~/(?:,\s*)?params\s*=\s*{((?:{[^}]*}|[^{}]+)*)}/.map
		( 
			dsl.data, 
			this._parse
		);
		
		return result;
	}
	
	public function param() : {type: Null<ComplexType>, block: Array<Expr>}
	{
		return { type: this._param, block: this._initBlock };
	}
	
	function _parse( ereg : EReg ) : String
	{//trace( ereg );
		var matched = ereg.matched( 1 );
		var startPos =  ereg.matchedPos().pos + ereg.matched( 0 ).indexOf( '{' ) -6;
	//trace( matched );	
		//short way but not the best way for displaying errors with right positions
		var e = Context.parse( "var o:{" + matched + "}", Context.makePosition( { min: startPos, max: startPos+matched.length, file: this._dsl.path } ) );

		this._param = switch( e.expr )
		{
			case EVars(a):
					a[0].type;
			case _:
				null;
		}

		//Return empty spaces to not modify file positions
		var result = "";
		for ( i in 0...matched.length ) result += " ";
		//trace( this._param );
		return result;
	}
	
	public static function getType( field : String, ?runtimeParam : hex.preprocess.RuntimeParam ) : String
	{
		if ( runtimeParam != null )
		{
			switch( runtimeParam.type )
			{
				case TAnonymous( ref ): 
					for ( e in ref )
					{
						if ( e .name == field )
						{
							switch( e.kind )
							{
								case FVar( t ):
									return MacroUtil.getFQCNFromComplexType( t );
									
								case var wtf:
									trace( field, wtf );
							}
						}
					}
				case var wtf:
					//trace( field, wtf );
			}
		}
		else
		{
			
		}
		
		
		return null;
	}
	
	public static function getTypes( runtimeParam : hex.preprocess.RuntimeParam ) : Array<{ name: String, type: String, pos: Position }>
	{
		var a = [];
		
		switch( runtimeParam.type )
		{
			case TAnonymous( ref ): 
				
				for ( e in ref )
				{
					switch( e.kind )
					{
						case FVar( t ):
							a.push( { name: e .name, type: MacroUtil.getFQCNFromComplexType( t ), pos: e.pos } );
							
						case var wtf:
							trace( runtimeParam.type, wtf );
					}

				}
			case var wtf:
				//trace( runtimeParam.type, wtf );
		}
		
		return a;
	}
}

typedef Param =
{
	public var key 			: String;
	public var value 		: haxe.macro.Expr;
	public var position 	: {index:Int, length:Int};
}
#end