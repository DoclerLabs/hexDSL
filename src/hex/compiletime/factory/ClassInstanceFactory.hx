package hex.compiletime.factory;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import hex.compiletime.factory.ArgumentFactory;
import hex.di.IInjectorContainer;
import hex.error.PrivateConstructorException;
import hex.util.MacroUtil;
import hex.compiletime.basic.vo.FactoryVOTypeDef;

/**
 * ...
 * @author Francis Bourre
 */
class ClassInstanceFactory
{
	/** @private */
    function new()
    {
        throw new PrivateConstructorException();
    }
		
	static public function build<T:FactoryVOTypeDef>( factoryVO : T ) : Expr
	{
		var result : Expr 	= null;
		var constructorVO 	= factoryVO.constructorVO;
		var idVar 			= constructorVO.ID;

		//build arguments
		var constructorArgs = ArgumentFactory.build( factoryVO );
	
		var tp 				= MacroUtil.getPack( constructorVO.className, constructorVO.filePosition );
		var typePath 		= MacroUtil.getTypePath( constructorVO.className, constructorVO.filePosition );

		//build instance
		var staticCall 		= constructorVO.staticCall;
		var factoryMethod 	= constructorVO.factory;
		var staticRef 		= constructorVO.staticRef;
		var classType 		= MacroUtil.getClassType( constructorVO.className, constructorVO.filePosition );
		
		if ( constructorVO.injectorCreation && 
			MacroUtil.implementsInterface( classType, MacroUtil.getClassType( Type.getClassName( IInjectorContainer ) ) ) )
		{
			result = macro 	@:pos( constructorVO.filePosition ) 
				var $idVar = __applicationContextInjector.instantiateUnmapped( $p { tp } ); 

		}
		else if ( factoryMethod != null )//factory method
		{
			//TODO implement the same behavior @runtime issue#1
			if ( staticRef != null )//static variable - with factory method
			{
				//Assign right type description
				constructorVO.type = MacroUtil.getFQCNFromExpression( macro $p { tp } .$staticRef.$factoryMethod( $a { constructorArgs } ) );

				result = macro 	@:pos( constructorVO.filePosition ) 
								var $idVar = $p { tp } .$staticRef.$factoryMethod( $a { constructorArgs } ); 
			}
			else if ( staticCall != null )//static method call - with factory method
			{
				//Assign right type description
				constructorVO.type = MacroUtil.getFQCNFromExpression( macro $p { tp } .$staticCall().$factoryMethod( $a { constructorArgs } ) );
			
				result = macro 	@:pos( constructorVO.filePosition ) 
								var $idVar = $p { tp }.$staticCall().$factoryMethod( $a{ constructorArgs } ); 
			}
			else//factory method error
			{
				Context.error( 	"'" + factoryMethod + "' method cannot be called on '" +  constructorVO.className + 
								"' class. Add static method or variable to make it working.", constructorVO.filePosition );
			}
		}
		else if ( staticCall != null )//simple static method call
		{
			//Assign right type description
			try 
			{
				constructorVO.type = MacroUtil.getFQCNFromExpression( macro $p { tp } .$staticCall( $a { constructorArgs } ) );
			}
			catch( e : Dynamic )
			{
				//TODO Find a better way
				var args = [];
				for ( i in 0...constructorArgs.length ) args.push( macro null );
				constructorVO.type = MacroUtil.getFQCNFromExpression( macro $p { tp } .$staticCall( $a { args } ) );
			}
			
			result = macro 	@:pos( constructorVO.filePosition ) 
							var $idVar = $p { tp } .$staticCall( $a { constructorArgs } );
		}
		else//Standard instantiation
		{
			var varType = 
				TypeTools.toComplexType( 
					Context.typeof( 
						Context.parseInlineString( '( null : ${constructorVO.type})', constructorVO.filePosition ) ) );
			
			result = macro @:pos( constructorVO.filePosition )
								var $idVar : $varType = new $typePath( $a { constructorArgs } ); 
							

		}
		
		return macro @:pos( constructorVO.filePosition ) $result;
	}
}
#end