package hex.runtime.factory;

import hex.core.IApplicationContext;
import hex.runtime.basic.IRunTimeContextFactory;
import hex.runtime.basic.IRunTimeCoreFactory;
import hex.runtime.basic.vo.FactoryVOTypeDef;
import hex.unittest.assertion.Assert;
import hex.vo.ConstructorVO;

using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class BoolFactoryTest
{
	@Test( "Test execute with true argument" )
    public function testExecuteWithTrueArgument() : Void
    {
		var constructorVO = new ConstructorVO( "test", "Bool", ["true"] );
		Assert.isTrue( BoolFactory.build( this._getFactoryVO( constructorVO ) ), "constructorVO.result should be true" );
	}
	
	@Test( "Test execute with false argument" )
    public function testExecuteWithFalseArgument() : Void
    {
		var constructorVO = new ConstructorVO( "test", "Bool", ["false"] );
		Assert.isFalse( BoolFactory.build( this._getFactoryVO( constructorVO ) ), "constructorVO.result should be false" );
	}
	
	@Test( "Test execute with invalid argument" )
    public function testExecuteWithInvalidArgument() : Void
    {
		var constructorVO = new ConstructorVO( "test", "Bool", ["a"] );
		Assert.methodCallThrows( IllegalArgumentException, BoolFactory, BoolFactory.build, [ this._getFactoryVO( constructorVO ) ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var constructorVO = new ConstructorVO( "test", "Bool", null );
		Assert.methodCallThrows( IllegalArgumentException, BoolFactory, BoolFactory.build, [ this._getFactoryVO( constructorVO ) ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var constructorVO = new ConstructorVO( "test", "Bool", [] );
		Assert.methodCallThrows( IllegalArgumentException, BoolFactory, BoolFactory.build, [ this._getFactoryVO( constructorVO ) ], "command execution should throw IllegalArgumentException" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var constructorVO = new ConstructorVO( "test", "Bool", [null] );
		Assert.methodCallThrows( IllegalArgumentException, BoolFactory, BoolFactory.build, [ this._getFactoryVO( constructorVO ) ], "command execution should throw IllegalArgumentException" );
	}

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