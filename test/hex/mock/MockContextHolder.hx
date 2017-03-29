package hex.mock;

import hex.core.IApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockContextHolder 
{
	public var context : IApplicationContext;

	public function new( context : IApplicationContext ) 
	{
		this.context = context;
	}
}