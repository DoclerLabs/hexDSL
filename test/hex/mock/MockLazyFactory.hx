package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockLazyFactory 
{
	function new() { }

	public static function getLazy<T>( value : T ) return value;
}