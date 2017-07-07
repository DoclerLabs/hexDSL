package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class LazyClass 
{
	public static var value : Any;
	
	public function new( o : Any ) 
	{
		LazyClass.value = o;
	}
}