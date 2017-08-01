package hex.compiletime;

import hex.compiletime.flow.BasicStaticFlowCompiler;
import hex.compiletime.xml.BasicStaticXmlCompiler;
import hex.core.IApplicationAssembler;
import hex.domain.ApplicationDomainDispatcher;
import hex.mock.LazyProvider;
import hex.mock.MockClassWithoutArgument;
import hex.mock.MockRectangle;
import hex.runtime.ApplicationAssembler;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class MixedDslTest 
{
	var _applicationAssembler : IApplicationAssembler;

	@Before
	public function setUp() : Void
	{
		this._applicationAssembler = new ApplicationAssembler();
	}
	
	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.getInstance().clear();
		this._applicationAssembler.release();
	}

	/*@Test( "test Flow and Xml mixed" )
	public function testFlowAndXmlMixed() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/multipleInstancesWithReferences.xml", "MixedDslTest_testFlowXmlMixed" );
		var code2 = BasicStaticFlowCompiler.extend( code, "context/flow/simpleInstanceWithoutArguments.flow" );
		var code3 = BasicStaticXmlCompiler.extend( code, "context/xml/multipleInstancesWithReferencesReferenced.xml" );
		
		var locator = code.locator;
		var locator2 = code2.locator;
		var locator3 = code3.locator;
		
		//1st pass
		code.execute();

		var rectSize = locator.rectSize;

		Assert.equals( 30, rectSize.x );
		Assert.equals( 40, rectSize.y );

		var rectPosition = locator.rectPosition;
		Assert.equals( 10, rectPosition.x );
		Assert.equals( 20, rectPosition.y );

		var rect = ( locator.rect : MockRectangle );
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.size.x );
		Assert.equals( 40, rect.size.y );
		
		//2nd pass
		code2.execute();
		
		Assert.isInstanceOf( locator2.instance, MockClassWithoutArgument );
		Assert.equals( locator.rectSize, locator2.rectSize );
		
		//3rd pass
		code3.execute();
		
		var anotherRect = ( locator3.anotherRect : MockRectangle);
		Assert.isInstanceOf( anotherRect, MockRectangle );
		Assert.equals( 10, anotherRect.x );
		Assert.equals( 20, anotherRect.y );
		Assert.equals( 30, anotherRect.size.x );
		Assert.equals( 40, anotherRect.size.y );
		
		//Check data synchronisation/integrity
		locator.rectSize = null;
		Assert.isNull( locator2.rectSize );
		Assert.isNull( locator3.rectSize );
		
		locator2.rectPosition = null;
		Assert.isNull( locator.rectPosition );
		
		Assert.equals( locator, locator2 );
		Assert.equals( locator, locator3 );
		Assert.equals( locator2, locator3 );
	}
	
	@Test( "test Flow and Xml mixed with imports" )
	public function testFlowAndXmlMixedWithImports() : Void
	{
		MockCustomStaticFlowParser.prepareCompiler();
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/static/sizeWithXmlImport.flow", "MixedDslTest_testFlowAndXmlMixedWithImports" );
		code.execute( {x:10, y:20} );

		Assert.equals( 10, code.locator.sizeContext.size.width );
		Assert.equals( 20, code.locator.sizeContext.size.height );
		
		Assert.equals( 10, code.locator.width );
		Assert.equals( 20, code.locator.height );
		
		Assert.equals( 30, code.locator.sum );
		Assert.equals( 'width is 10 and height is 20. Sum is 30', code.locator.concatenation );
	}*/
	
	
}