package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class LazyProvider 
{
	public static var value : Any;
	
	public function new() {}
	
	public static function provide<T>( o : T ) : T
	{
		LazyProvider.value = o;
		return o;
	}
}