package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockCollectionOwner 
{
	public var collection : Array<Int>;

	public function new() {}
	
	@:keep
	public function setCollection( a : Array<Int> )
	{
		this.collection = a;
	}
}