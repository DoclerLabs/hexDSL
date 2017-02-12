package hex.runtime.basic;

/**
 * ...
 * @author Francis Bourre
 */
class FastEval
{
	function new() 
	{
		
	}
	
	static public function fromTarget( target : Dynamic, toEval : String, coreFactory : IRunTimeCoreFactory ) : Dynamic
	{
		var members : Array<String> = toEval.split( "." );
		var result 	: Dynamic;
		
		while ( members.length > 0 )
		{
			var member : String = members.shift();
			result = Reflect.field( target, member );
			
			target = result;
		}
		
		return target;
	}
	
}