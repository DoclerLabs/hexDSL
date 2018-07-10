package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class ConstructorWithAnonStruct 
{
	public var o: {s:String};
	
	public function new( arg: { s: String } ) 
	{
		this.o = arg;
	}
	
	public function getString() : String
	{
		return o.s;
	}
}