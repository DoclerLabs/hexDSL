package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class ClassWithArgument 
{
	public var arg : ClassWithArgument;
	
	public function new( ?arg : ClassWithArgument ) 
	{
		this.arg = arg;
	}
	
	public static function getInstance( ?arg : ClassWithArgument ) : ClassWithArgument
	{
		return new ClassWithArgument( arg );
	}
	
	public function clone() : ClassWithArgument
	{
		return new ClassWithArgument( arg );
	}
}