package hex.compiletime.flow.parser.custom;

import haxe.macro.Expr;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class MappingParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	public static function parse( id : String, params : Array<Expr>, originalExpression : Expr ) : ConstructorVO
	{
		var constructorVO : ConstructorVO;
		
		switch( params[ 0 ].expr )
		{
			case EObjectDecl( fields ):
				
				var args = [];
				var it = fields.iterator();
				while ( it.hasNext() )
				{
					var argument = it.next();
					args.push( ObjectParser.getProperty( id, argument.field, argument.expr ) );
				}

				constructorVO = new ConstructorVO( id, ContextTypeList.MAPPING_DEFINITION, args );
				constructorVO.filePosition = params[0].pos;
			
			case wtf:
				trace( wtf );
				haxe.macro.Context.error( '', haxe.macro.Context.currentPos() );
		}
		
		constructorVO.filePosition = originalExpression.pos;
		return constructorVO;
	}
}