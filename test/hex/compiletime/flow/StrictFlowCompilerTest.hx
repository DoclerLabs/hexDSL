package hex.compiletime.flow;

import hex.core.IApplicationAssembler;
import hex.core.ICoreFactory;
import hex.domain.ApplicationDomainDispatcher;
import hex.mock.MockChat;
import hex.mock.MockProxy;
import hex.mock.MockReceiver;
import hex.mock.MockRectangle;
import hex.runtime.ApplicationAssembler;
import hex.runtime.basic.ApplicationContext;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class StrictFlowCompilerTest 
{
	var _applicationAssembler 		: IApplicationAssembler;
	
	static var applicationAssembler : IApplicationAssembler;

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
	
	function _getCoreFactory() : ICoreFactory
	{
		return this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();
	}
	
	/*@Test( "test building String" )
	public function testBuildingString() : Void
	{
		var context = StrictFlowCompiler.compile( "context/flow/testBuildingString.flow" );
		Assert.equals( "hello", context.s );
	}*/
	
	/*@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		var context = StrictFlowCompiler.compile( "context/flow/simpleInstanceWithArguments.flow" );

		Assert.isInstanceOf( context.size, Size );
		Assert.equals( 10, context.size.width );
		Assert.equals( 20, context.size.height );
	}*/
	
	/*@Test( "test building multiple instances with arguments" )
	public function testBuildingMultipleInstancesWithArguments() : Void
	{
		var context = StrictFlowCompiler.compile( "context/flow/multipleInstancesWithArguments.flow" );
		
		var rect = context.rect;
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.width );
		Assert.equals( 40, rect.height );
		
		var size = context.size;
		Assert.isInstanceOf( size, Size );
		Assert.equals( 15, size.width );
		Assert.equals( 25, size.height );

		var position = context.position;
		Assert.equals( 35, position.x );
		Assert.equals( 45, position.y );
	}
	
	@Test( "test building single instance with primitives references" )
	public function testBuildingSingleInstanceWithPrimitivesReferences() : Void
	{
		var context = StrictFlowCompiler.compile( "context/flow/singleInstanceWithPrimReferences.flow" );
		
		var x = context.x;
		Assert.equals( 1, x );
		
		var y = context.y;
		Assert.equals( 2, y );

		var position = context.position;
		Assert.equals( 1, position.x );
		Assert.equals( 2, position.y );
	}
	
	@Test( "test building single instance with method references" )
	public function testBuildingSingleInstanceWithMethodReferences() : Void
	{
		var context = StrictFlowCompiler.compile( "context/flow/singleInstanceWithMethodReferences.flow" );
		
		var chat = context.chat;
		Assert.isInstanceOf( chat, MockChat );
		
		var receiver = context.receiver;
		Assert.isInstanceOf( receiver, MockReceiver );
		
		var proxyChat = context.proxyChat;
		Assert.isInstanceOf( proxyChat, MockProxy );
		
		var proxyReceiver = context.proxyReceiver;
		Assert.isInstanceOf( proxyReceiver, MockProxy );

		Assert.equals( chat, proxyChat.scope );
		Assert.equals( chat.onTranslation, proxyChat.callback );
		
		Assert.equals( receiver, proxyReceiver.scope );
		Assert.equals( receiver.onMessage, proxyReceiver.callback );
	}
	
	@Test( "test building multiple instances with references" )
	public function testAssignInstancePropertyWithReference() : Void
	{
		var context = StrictFlowCompiler.compile( "context/flow/instancePropertyWithReference.flow" );
		
		var width = context.width;
		Assert.equals( 10, width );
		
		var height = context.height;
		Assert.equals( 20, height );
		
		var size = context.size;
		Assert.equals( width, size.x );
		Assert.equals( height, size.y );
		
		var rect = context.rect;
		Assert.equals( width, rect.size.x );
		Assert.equals( height, rect.size.y );
	}*/
	
	@Test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		var context = StrictFlowCompiler.compile( "context/flow/multipleInstancesWithReferences.flow" );
		var context2 = StrictFlowCompiler.compile( "context/flow/simpleInstanceWithoutArguments.flow" );
		
		Assert.equals( context.rectSize, context2.rectSize );
		
		var rectSize = context.rectSize;

		Assert.equals( 30, rectSize.x );
		Assert.equals( 40, rectSize.y );

		var rectPosition = context.rectPosition;
		Assert.equals( 10, rectPosition.x );
		Assert.equals( 20, rectPosition.y );

		var rect = ( context.rect : MockRectangle);
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.size.x );
		Assert.equals( 40, rect.size.y );
		
		//Should not work because it's defined in context2
		/*trace( context.instance );*/
		
		//Should autocomplete but it doesn't 
		//Only the method and the members of the second iteration are auto-completing
		//Btw, it compiles...
		/*context2.rectSize;*/
	}
}
