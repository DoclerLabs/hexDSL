package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockUtil 
{
	function new() 
	{
		
	}
	
	public static function concat<T>( a1: Array<T>, a2: Array<T> ) : Array<T>
	{
		return a1.concat( a2 );
	}
	
	#if js
	public static inline function querySelector<T>( path : String ) : T
	{
		return js.Browser.supported ? cast js.Browser.document.querySelector( path ) : null;
	}
	#end
}