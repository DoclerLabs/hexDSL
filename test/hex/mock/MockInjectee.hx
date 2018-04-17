package hex.mock;

import hex.di.IInjectorContainer;
import hex.mock.IMockInjectee;

/**
 * ...
 * @author Francis Bourre
 */
class MockInjectee implements IInjectorContainer implements IMockInjectee
{
	@Inject
	public var domain : MockObject;
	
	public function new() 
	{
		
	}
}