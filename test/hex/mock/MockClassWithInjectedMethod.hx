package hex.mock;

import hex.di.IInjectorContainer;
import hex.mock.MockModuleWithInternalType.FunctionSignature;

/**
 * ...
 * @author Francis Bourre
 */
class MockClassWithInjectedMethod implements IInjectorContainer
{
	@Inject("f")
	public var toInject1 : FunctionSignature;
	
	@Inject("f2")
	public var toInject2 : FunctionSignature;
	
	@Inject("f")
	public var toInject1b : String->String;
	
	@Inject("f2")
	public var toInject2b : String->String;
	
	@Inject("f")
	public var toInject1c : hex.mock.MockModuleWithInternalType.FunctionSignature;
	
	@Inject("f2")
	public var toInject2c : hex.mock.MockModuleWithInternalType.FunctionSignature;
	
	public function new() 
	{
		
	}
}