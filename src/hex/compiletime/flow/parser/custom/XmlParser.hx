package hex.compiletime.flow.parser.custom;

#if macro
import haxe.macro.Expr;
import hex.compiletime.flow.parser.ExpressionUtil;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class XmlParser 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	public static function parse( id : String, params : Array<Expr>, originalExpression : Expr ) : ConstructorVO
	{
		var constructorVO : ConstructorVO;
		
		switch( params[ 0 ].expr )
		{
			case EConst(CString(xml)):
				
				if ( params.length == 1 )
				{
					constructorVO = new ConstructorVO( id, ContextTypeList.XML, [xml]  );
				}
				else if ( params.length == 2 )
				{
					switch( params[ 1 ].expr )
					{
						case EField( ee, ff ):
							var factory = ExpressionUtil.compressField( params[ 1 ] );
							constructorVO = new ConstructorVO( id, ContextTypeList.XML, [xml], factory  );

						case wtf:
							trace( wtf );
							haxe.macro.Context.error( '', haxe.macro.Context.currentPos() );
					}
				}
				
				
			case wtf:
				trace( wtf );
				haxe.macro.Context.error( '', haxe.macro.Context.currentPos() );
		}
		
		constructorVO.filePosition = originalExpression.pos;
		return constructorVO;
	}
}
#end