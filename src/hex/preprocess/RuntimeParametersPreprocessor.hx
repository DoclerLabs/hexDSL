package hex.preprocess;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiletime.DSLData;

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
		
		var result = ~/(?:,\s*)?params\s*=\s*\{([^}]+|\n)}/.map
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
	{
		var matched = ereg.matched( 1 );
		var startPos =  ereg.matchedPos().pos + ereg.matched( 0 ).indexOf( '{' ) -6;
		
		//short way but not the best way for displaying errors with right positions
		var e = Context.parse( "var o:{" + matched + "}", Context.makePosition( { min: startPos, max: startPos+matched.length, file: this._dsl.path } ) );

		this._param = switch( e.expr )
		{
			case EVars(a):
					a[0].type;
			case _:
				null;
		}
		
		var split = matched.split(' ').join('').split( ':' );
		for ( i in 0...split.length-1 )
		{
			var element = split[ i ];
			var index 	= element.lastIndexOf(',');
			var key 	= element.substring( index + 1 );
			var exp = "var " + key + " = param." + key;
			this._initBlock.push( Context.parse( exp, Context.currentPos() ) );
		}


		//TODO better position error tracking
		/*this._param = TAnonymous([
			{ name:'you', kind: FVar(macro:Bool), pos: Context.currentPos() },
			{ name:'another', kind: FVar(TypeTools.toComplexType(Context.getType('hex.structures.Size'))), pos: Context.currentPos() }
		]);*/

		/*
		this._param = 
		{ 
			expr: TAnonymous([]), 
			pos: haxe.macro.Context.makePosition( { min: startPos, max: startPos + matched.length, file: this.dsl.path } )
		};*/

		//{ expr => EVars([{ expr => null, name => o, type => TAnonymous([{ kind => FVar(TPath({ name => Int, pack => [], params => [] }),null), meta => [], name => test, ??? => #pos(hexDsl/test/context/flow/runtimeArguments.flow:1: characters 61-65), doc => null, pos => #pos(hexDsl/test/context/flow/runtimeArguments.flow:1: characters 61-69), access => [] },{ kind => FVar(TPath({ name => Point, pack => [hex,structures], params => [TPType(TPath({ name => T, pack => [], params => [] })),TPType(TPath({ name => U, pack => [], params => [] }))] }),null), meta => [], name => another, ??? => #pos(hexDsl/test/context/flow/runtimeArguments.flow:1: characters 71-78), doc => null, pos => #pos(hexDsl/test/context/flow/runtimeArguments.flow:1: characters 71-105), access => [] },{ kind => FVar(TPath({ name => Bool, pack => [], params => [] }),null), meta => [], name => last, ??? => #pos(hexDsl/test/context/flow/runtimeArguments.flow:1: characters 107-111), doc => null, pos => #pos(hexDsl/test/context/flow/runtimeArguments.flow:1: characters 107-116), access => [] }]), ??? => #pos(hexDsl/test/context/flow/runtimeArguments.flow:1: characters 58-59) }]), pos => #pos(hexDsl/test/context/flow/runtimeArguments.flow:1: characters 54-109) }

		//var strippedSpaces = matched.split(' ').join('');
		/*var split = matched.split(' ').join('').split( ':' );

		var buf = "";
		var params : Array<Param> = [];
		for ( i in 0...split.length-1 )
		{
			var element = split[ i ];
			var index 	= element.lastIndexOf(',');
			var key 	= element.substring( index + 1 );
			split[ i ] 	= element.substring(0, index) + (i == 0?"":";") + "var " + key;
			
			var param = { position: { index: 0, length: 0 }, key:key.split(' ').join(''), value: macro true };
			params.push( param );
		}
		
		var exprs = split.join( ':' ).split( ';' );
		for ( i in 0...exprs.length )
		{
			var param = params[ i ];
			var start = 0;
			var end = 0;
			param.value = haxe.macro.Context.parse( exprs[ i ], haxe.macro.Context.makePosition( { min: start, max: end, file: this.dsl.path } ) );
			this._params.set( param.key, param.value );
		}*/

		//Return empty spaces to not modify file positions
		var result = "";
		for ( i in 0...matched.length ) result += " ";
		return result;
	}
}

typedef Param =
{
	public var key 			: String;
	public var value 		: haxe.macro.Expr;
	public var position 	: {index:Int, length:Int};
}
#end