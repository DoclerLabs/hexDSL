package hex.compiletime.xml;

import hex.core.ICoreFactory;
import hex.domain.ApplicationDomainDispatcher;
import hex.mock.MockApplicationContext;
import hex.runtime.ApplicationAssembler;
import hex.runtime.basic.ApplicationContext;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationContextBuildingTest
{
	var _applicationAssembler : ApplicationAssembler;
		
	@Before
	public function setUp() : Void
	{
		this._applicationAssembler 	= new ApplicationAssembler();
	}

	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.release();
		this._applicationAssembler.release();
	}
		
	function _getCoreFactory() : ICoreFactory
	{
		return this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();
	}
	
	@Test( "test applicationContext building" )
	public function testApplicationContextBuilding() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/applicationContextBuildingTest.xml" );
		
		var applicationContext = this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext );
		Assert.isNotNull( applicationContext, "applicationContext shouldn't be null" );
		Assert.isInstanceOf( applicationContext, MockApplicationContext, "applicationContext shouldn't be an instance of 'MockApplicationContext'" );
		Assert.equals( "Hola Mundo", applicationContext.getCoreFactory().locate( "test" ), "String values should be the same" );
	}
}