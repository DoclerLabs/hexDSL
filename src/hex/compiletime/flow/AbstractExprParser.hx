package hex.compiletime.flow;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiletime.DSLParser;
import hex.core.IApplicationContext;

using hex.util.MacroUtil;
using hex.compiletime.flow.parser.ExpressionUtil;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractExprParser<RequestType> extends DSLParser<Expr, RequestType>
{
	function new() 
	{
		super();
	}
	
	@final
	public function getApplicationContext() : IApplicationContext
	{
		return this._applicationAssembler.getApplicationContext( this._applicationContextName, this._applicationContextDefaultClass );
	}
	
	@final
	override public function setContextData( data : Expr ) : Void
	{
		super.setContextData( data );
	}
	
	override function _findApplicationContextName( data : Expr ) : String
	{
		return switch( data.expr )
		{
			case EMeta( entry, e ):

				if ( entry.name == ContextKeywordList.CONTEXT )
				{
					var name = null;
				
					var a = Lambda.filter( entry.params, function ( p ) 
						{ 
							return switch( p.expr ) 
							{
								case EBinop( OpAssign, _.expr => EConst(CIdent(ContextKeywordList.NAME)), e2 ) : true;
								case _: false;
							}
						} );

					if ( a.length == 1 )
					{
						name = switch( a.first().expr )
						{
							case EBinop( OpAssign, e1, _.expr => EConst(CString(id)) ) :
								id;
								
							case _:
								null;
						}
					}

					name;
				}
				else
				{
					this._findApplicationContextName( e );
				}
				
				
			case _ :
				null;
		}
	}
	
	override function _findApplicationContextClass( data : Expr ) : {name: String, pos: haxe.macro.Expr.Position}
	{
		return switch( data.expr )
		{
			case EMeta( entry, e ):
				
				if ( entry.name == ContextKeywordList.CONTEXT )
				{
					var name = null;
				
					var a = Lambda.filter( entry.params, function ( p ) 
						{ 
							return switch( p.expr ) 
							{
								case EBinop( OpAssign, _.expr => EConst(CIdent(ContextKeywordList.TYPE)), e2 ) : true;
								case _: false;
							}
						} );

					if ( a.length == 1 )
					{
						name = switch( a.first().expr )
						{
							case EBinop( OpAssign, e1, e2 ) :
								e2.expr.compressField();
								
							case _:
								null;
						}
					}

					{name: name, pos: e.pos};
				}
				else
				{
					this._findApplicationContextClass( e );
				}

				
				
			case _ :
				null;
		}
	}
	
	function _getExpressions() : Array<Expr>
	{
		var e = this._contextData;

		switch( e.expr )
		{
			case EMeta( entry, _.expr => EBlock( exprs ) ) if ( entry.name == ContextKeywordList.CONTEXT ):
				return exprs;
			case _:
		}
		
		return [];
	}
}
#end