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
								e2.compressField();
								
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
		return this._searchForMainBlock( this._contextData );
	}
	
	function _searchForMainBlock( e )
	{
		return switch( e.expr )
		{
			case EMeta( entry, e ):
				_searchForMainBlock( e );
			case EBlock( exprs ):
				exprs;
			case _:
				null;
		}
	}
	
	function transformContextData( f : Array<Expr>->Array<Expr> )
	{
		this._contextData = { expr: this._doOnMainBlock( this._contextData.expr, f ), pos: this._contextData.pos };
	}
	
	function _doOnMainBlock( parsed : ExprDef, f : Array<Expr>->Array<Expr> ) : ExprDef
	{
		return switch( parsed )
		{
			case EMeta( entry, e ):
				EMeta( entry,  {expr: _doOnMainBlock( e.expr, f ), pos: e.pos} );
				
			case EBlock( exprs ):
				EBlock( f( exprs ) );
				
			case _:
				parsed;
		}
	}
}
#end