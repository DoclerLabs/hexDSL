package hex.runtime.factory;

import hex.core.IApplicationContext;
import hex.error.IllegalArgumentException;
import hex.runtime.basic.IRunTimeContextFactory;
import hex.runtime.basic.IRunTimeCoreFactory;
import hex.runtime.basic.vo.FactoryVOTypeDef;
import hex.unittest.assertion.Assert;
import hex.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class UIntFactoryTest
{
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var constructorVO = new ConstructorVO( "test", "UInt", ["4"] );
		Assert.equals( 4, UIntFactory.build( this._getFactoryVO( constructorVO ) ), "constructorVO.result should equal 4" );
	}
	
	@Ignore( "Test execute with negative argument value" )
    public function testExecuteWithNegativeArgumentValue() : Void
    {
		var constructorVO = new ConstructorVO( "test", "UInt", ["-4"] );
		Assert.methodCallThrows( IllegalArgumentException, UIntFactory, UIntFactory.build, [ this._getFactoryVO( constructorVO ) ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var constructorVO = new ConstructorVO( "test", "UInt", null );
		Assert.methodCallThrows( IllegalArgumentException, UIntFactory, UIntFactory.build, [ this._getFactoryVO( constructorVO ) ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var constructorVO = new ConstructorVO( "test", "UInt", [] );
		Assert.methodCallThrows( IllegalArgumentException, UIntFactory, UIntFactory.build, [ this._getFactoryVO( constructorVO ) ], "command execution should throw IllegalArgumentException" );
	}
	
	#if !neko
	@Test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var constructorVO = new ConstructorVO( "test", "UInt", ["a"] );
		Assert.methodCallThrows( IllegalArgumentException, UIntFactory, UIntFactory.build, [ this._getFactoryVO( constructorVO ) ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var constructorVO = new ConstructorVO( "test", "UInt", [ null ] );
		Assert.methodCallThrows( IllegalArgumentException, UIntFactory, UIntFactory.build, [ this._getFactoryVO( constructorVO ) ], "command execution should throw IllegalArgumentException" );
	}
	#end
	
	function _getFactoryVO( constructorVO : ConstructorVO = null ) : FactoryVOTypeDef
	{
		return { constructorVO : constructorVO, contextFactory : new MockContextFactory() };
	}
}

private class MockContextFactory implements IRunTimeContextFactory
{
	public function new()	
	{
		
	}
	
	public function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		return null;
	}
	
	public function buildObject( id : String ) : Void
	{
		
	}
	
	public function getApplicationContext() : IApplicationContext
	{
		return null;
	}
	
	public function getCoreFactory() : IRunTimeCoreFactory
	{
		return null;
	}
}