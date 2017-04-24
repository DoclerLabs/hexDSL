package hex.mock;

import hex.runtime.basic.ApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class MockApplicationContext extends ApplicationContext
{
	public function new( applicationContextName : String ) 
	{
		super( applicationContextName );
	}
	
	public function getTest() : String
	{
		return 'test';
	}
}