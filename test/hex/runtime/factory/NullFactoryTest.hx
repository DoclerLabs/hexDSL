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
class NullFactoryTest
{
	@Test( "Test execute" )
    public function testExecute() : Void
    {
		var constructorVO = new ConstructorVO( "test" );
		Assert.isNull( NullFactory.build( this._getFactoryVO( constructorVO ) ), "constructorVO.result should be null" );
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