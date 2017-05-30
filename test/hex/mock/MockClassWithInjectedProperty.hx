package hex.mock;

import hex.di.IInjectorContainer;

/**
 * ...
 * @author Francis Bourre
 */
class MockClassWithInjectedProperty implements IInjectorContainer
{
	@Inject( 'injected' )
	public var property : String;
	
	public var postConstructWasCalled : Bool = false;
	
	public function new() 
	{
		
	}
	
	@PostConstruct
	public function testPostConstruct() 
	{
		this.postConstructWasCalled = true;
	}
}