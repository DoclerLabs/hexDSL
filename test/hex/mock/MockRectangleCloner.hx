package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockRectangleCloner 
{
	static public function getRectangle( r : MockRectangle ) : MockRectangle
	{
		return new MockRectangle( r.x, r.y, r.width, r.height );
	}
}