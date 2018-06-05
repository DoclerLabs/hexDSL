package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class Reseter 
{
	public var resetMethod : Void->Void;
	
	public function new( resetMethod : Void->Void ) 
	{
		this.resetMethod = resetMethod;
	}
}