package hex.runtime.factory;

import hex.core.IApplicationContext;
import hex.runtime.basic.IRunTimeContextFactory;
import hex.runtime.basic.IRunTimeCoreFactory;
import hex.runtime.basic.vo.FactoryVOTypeDef;
import hex.unittest.assertion.Assert;
import hex.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class ArrayFactoryTest
{
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var constructorVO = new ConstructorVO( "test", "Array", 
			[ 
				new ConstructorVO( "test", "Int", [3] ), 
				new ConstructorVO( "test", 'String', ['hello world'] )
			] );
		
		var result = ArrayFactory.build( this._getFactoryVO( constructorVO ) );
		Assert.isInstanceOf( result, Array, "constructorVO.result should be an instance of Array class" );
		Assert.deepEquals( [3, "hello world"], result, "constructorVO.result should agregate the same elements" );
	}
	
	@Test( "Test execute with no argument array" )
    public function testExecuteWithNoArgumentArray() : Void
    {
		var constructorVO = new ConstructorVO( "test", "Array", [] );
		var result = ArrayFactory.build( this._getFactoryVO( constructorVO ) );
		Assert.isInstanceOf( result, Array, "constructorVO.result should be an instance of Array class" );
	}
	
	@Test( "Test execute with empty argument array" )
    public function testExecuteWithEmptyArgumentArray() : Void
    {
		var constructorVO = new ConstructorVO( "test", "Array", [] );
		var result = ArrayFactory.build( this._getFactoryVO( constructorVO ) );
		Assert.isInstanceOf( result, Array, "constructorVO.result should be an instance of Array class" );
	}
	
	@Test( "Test execute with null argument" )
    public function testExecuteWithNullArgument() : Void
    {
		var constructorVO = new ConstructorVO( "test", "Array", [ new ConstructorVO( '', "null" ) ] );
		var result = ArrayFactory.build( this._getFactoryVO( constructorVO ) );
		Assert.isInstanceOf( result, Array, "constructorVO.result should be an instance of Array class" );
		Assert.deepEquals( [null], result, "constructorVO.result should agregate the same elements" );
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
		return constructorVO.arguments != null ? constructorVO.arguments[ 0 ] : null;
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