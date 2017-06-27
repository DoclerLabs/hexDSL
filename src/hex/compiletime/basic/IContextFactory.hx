package hex.compiletime.basic;

/**
 * @author Francis Bourre
 */
interface IContextFactory
{
	function buildVO( constructorVO : hex.vo.ConstructorVO, ?id : String ) : Dynamic;
	
	function buildObject( id : String ) : Void;
	
	function getApplicationContext() : hex.core.IApplicationContext;
	
	function getCoreFactory() : hex.core.ICoreFactory;
	
	function getTypeLocator() : hex.collection.ILocator<String, String>;
}
