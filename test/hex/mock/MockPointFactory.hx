package hex.mock;

import hex.structures.Point;

/**
 * ...
 * @author Francis Bourre
 */
class MockPointFactory
{
	function new() 
	{
		
	}
	
	public function getPoint( x : Int, y : Int ) : Point
	{
		return new Point( x, y );
	}

	static var _Instance : MockPointFactory = null;

	static public function getInstance() : MockPointFactory
	{
		if ( MockPointFactory._Instance == null )
		{
			MockPointFactory._Instance = new MockPointFactory();
		}
		
		return MockPointFactory._Instance;
	}
}