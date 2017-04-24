package hex.compiletime.flow;

import hex.core.IApplicationAssembler;
import hex.di.Injector;
import hex.di.mapping.MappingConfiguration;
import hex.domain.ApplicationDomainDispatcher;
import hex.error.NoSuchElementException;
import hex.mock.AnotherMockClass;
import hex.mock.IAnotherMockInterface;
import hex.mock.IMockInterface;
import hex.mock.MockCaller;
import hex.mock.MockChat;
import hex.mock.MockClass;
import hex.mock.MockClassWithGeneric;
import hex.mock.MockClassWithInjectedProperty;
import hex.mock.MockClassWithoutArgument;
import hex.mock.MockMethodCaller;
import hex.mock.MockProxy;
import hex.mock.MockReceiver;
import hex.mock.MockRectangle;
import hex.mock.MockServiceProvider;
import hex.runtime.ApplicationAssembler;
import hex.runtime.basic.ApplicationContext;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BasicStaticFlowCompilerTest 
{
	var _applicationAssembler : IApplicationAssembler;
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
	
	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testBuildingString.flow", "BasicStaticFlowCompiler_testBuildingString" );
		
		var locator = code.locator;
		Assert.isNull( locator.s );
		
		code.execute();
		
		Assert.equals( "hello", locator.s );
	}
	
	@Test( "test context reference" )
	public function testContextReference() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/contextReference.flow", "BasicStaticFlowCompiler_testContextReference" );
		code.execute();
		Assert.equals( code.applicationContext, code.locator.contextHolder.context );
	}
	
	@Test( "test building String without context name" )
	public function testBuildingStringWithoutContextName() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/contextWithoutName.flow", "BasicStaticFlowCompiler_testBuildingStringWithoutContextName" );
		code.execute();
		Assert.equals( "hello", code.locator.s );
	}
	
	@Test( "test building String with assembler static property" )
	public function testBuildingStringWithAssemblerStaticProperty() : Void
	{
		BasicStaticFlowCompilerTest.applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticFlowCompiler.compile( BasicStaticFlowCompilerTest.applicationAssembler, "context/flow/testBuildingString.flow", "BasicStaticFlowCompiler_testBuildingStringWithAssemblerStaticProperty" );
		code.execute();
		
		var s : String = BasicStaticFlowCompilerTest.applicationAssembler.getApplicationContext( "BasicStaticFlowCompiler_testBuildingStringWithAssemblerStaticProperty", ApplicationContext ).getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	//Reading twice the same context cannot be tested
	
	@Test( "test overriding context name" )
	public function testOverridingContextName() : Void
	{
		var code1 = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow", "BasicStaticFlowCompiler_testOverridingContextName1" );
		var code2 = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow", "BasicStaticFlowCompiler_testOverridingContextName2" );
		
		code1.execute();
		code2.execute();

		Assert.isInstanceOf( code1.locator.instance, MockClassWithoutArgument );
		Assert.isInstanceOf( code2.locator.instance, MockClassWithoutArgument );
		Assert.notEquals( code1.locator.instance, code2.locator.instance );
	}
	
	//Primitives
	@Test( "test building Int" )
	public function testBuildingInt() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testBuildingInt.flow", "BasicStaticFlowCompiler_testBuildingInt" );
		code.execute();
		Assert.equals( -3, code.locator.i );
	}
	
	@Test( "test building Hex" )
	public function testBuildingHex() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testBuildingHex.flow", "BasicStaticFlowCompiler_testBuildingHex" );
		code.execute();
		Assert.equals( 0xFFFFFF, code.locator.i );
	}
	
	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testBuildingBool.flow", "BasicStaticFlowCompiler_testBuildingBool" );
		code.execute();
		Assert.isTrue( code.locator.b );
	}
	
	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testBuildingUInt.flow", "BasicStaticFlowCompiler_testBuildingUInt" );
		code.execute();
		Assert.equals( 3, code.locator.i );
	}
	
	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testBuildingNull.flow", "BasicStaticFlowCompiler_testBuildingNull" );
		code.execute();
		Assert.isNull( code.locator.value );
	}
	
	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/anonymousObject.flow", "BasicStaticFlowCompiler_testBuildingAnonymousObject" );
		code.execute();
		
		//TODO make structure with typed properties
		var obj = code.locator.obj;

		Assert.equals( "Francis", obj.name );
		Assert.equals( 44, obj.age );
		Assert.equals( 1.75, obj.height );
		Assert.isTrue( obj.isWorking );
		Assert.isFalse( obj.isSleeping );
	}
	
	@Test( "test building simple instance without arguments" )
	public function testBuildingSimpleInstanceWithoutArguments() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow", "BasicStaticFlowCompiler_testBuildingSimpleInstanceWithoutArguments" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClassWithoutArgument );
	}
	
	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/simpleInstanceWithArguments.flow", "BasicStaticFlowCompiler_testBuildingSimpleInstanceWithArguments" );
		
		var locator = code.locator;
		Assert.isNull( locator.size );
		
		code.execute();

		Assert.isInstanceOf( locator.size, Size );
		Assert.equals( 10, locator.size.width );
		Assert.equals( 20, locator.size.height );
	}
	
	@Test( "test building multiple instances with arguments" )
	public function testBuildingMultipleInstancesWithArguments() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/multipleInstancesWithArguments.flow", "BasicStaticFlowCompiler_testBuildingMultipleInstancesWithArguments" );
		var locator = code.locator;
		code.execute();
		
		var rect = locator.rect;
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.width );
		Assert.equals( 40, rect.height );
		
		var size = locator.size;
		Assert.isInstanceOf( size, Size );
		Assert.equals( 15, size.width );
		Assert.equals( 25, size.height );

		var position = locator.position;
		Assert.equals( 35, position.x );
		Assert.equals( 45, position.y );
	}
	
	@Test( "test building single instance with primitives references" )
	public function testBuildingSingleInstanceWithPrimitivesReferences() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticFlowCompiler.compile( applicationAssembler, "context/flow/singleInstanceWithPrimReferences.flow", "BasicStaticFlowCompiler_testBuildingSingleInstanceWithPrimitivesReferences" );
		var locator = code.locator;
		code.execute();
		
		var x = locator.x;
		Assert.equals( 1, x );
		
		var y = locator.y;
		Assert.equals( 2, y );

		var position = locator.position;
		Assert.equals( 1, position.x );
		Assert.equals( 2, position.y );
	}
	
	@Test( "test building single instance with method references" )
	public function testBuildingSingleInstanceWithMethodReferences() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticFlowCompiler.compile( applicationAssembler, "context/flow/singleInstanceWithMethodReferences.flow", "BasicStaticFlowCompiler_testBuildingSingleInstanceWithMethodReferences" );
		var locator = code.locator;
		code.execute();
		
		var chat = locator.chat;
		Assert.isInstanceOf( chat, MockChat );
		
		var receiver = locator.receiver;
		Assert.isInstanceOf( receiver, MockReceiver );
		
		var proxyChat = locator.proxyChat;
		Assert.isInstanceOf( proxyChat, MockProxy );
		
		var proxyReceiver = locator.proxyReceiver;
		Assert.isInstanceOf( proxyReceiver, MockProxy );

		Assert.equals( chat, proxyChat.scope );
		Assert.equals( chat.onTranslation, proxyChat.callback );
		
		Assert.equals( receiver, proxyReceiver.scope );
		Assert.equals( receiver.onMessage, proxyReceiver.callback );
	}
	
	@Test( "test building multiple instances with references" )
	public function testAssignInstancePropertyWithReference() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticFlowCompiler.compile( applicationAssembler, "context/flow/instancePropertyWithReference.flow", "BasicStaticFlowCompiler_testAssignInstancePropertyWithReference" );
		var locator = code.locator;
		code.execute();
		
		var width = locator.width;
		Assert.equals( 10, width );
		
		var height = locator.height;
		Assert.equals( 20, height );
		
		var size = locator.size;
		Assert.equals( width, size.x );
		Assert.equals( height, size.y );
		
		var rect = locator.rect;
		Assert.equals( width, rect.size.x );
		Assert.equals( height, rect.size.y );
	}
	
	@Test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticFlowCompiler.compile( applicationAssembler, "context/flow/multipleInstancesWithReferences.flow", "BasicStaticFlowCompiler_testBuildingMultipleInstancesWithReferences" );
		var code2 = BasicStaticFlowCompiler.extend( code, "context/flow/simpleInstanceWithoutArguments.flow" );
		var code3 = BasicStaticFlowCompiler.extend( code, "context/flow/multipleInstancesWithReferencesReferenced.flow" );
		
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

		var rect = ( locator.rect : MockRectangle);
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
	
	@Test( "test applicationContext building" )
	public function testApplicationContextBuilding() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code1 = BasicStaticFlowCompiler.compile( applicationAssembler, "context/flow/applicationContextBuildingTest.flow", "BasicStaticFlowCompiler_testApplicationContextBuilding1" );
		
		//application assembler reference stored
		Assert.equals( applicationAssembler, code1.applicationAssembler );
		
		//Custom application context is available before code execution
		Assert.equals( code1.applicationContext, code1.locator.BasicStaticFlowCompiler_testApplicationContextBuilding1 );
		
		//auto-completion is woking on custom applicationContext's class
		Assert.equals( 'test', code1.applicationContext.getTest() );
		Assert.equals( 'test', code1.locator.BasicStaticFlowCompiler_testApplicationContextBuilding1.getTest() );
		
		//
		code1.execute();

		//
		Assert.isInstanceOf( code1.locator.BasicStaticFlowCompiler_testApplicationContextBuilding1, hex.mock.MockApplicationContext );
		Assert.equals( "Hola Mundo", code1.locator.test );
		
		//
		var code2 = BasicStaticFlowCompiler.compile( applicationAssembler, "context/flow/applicationContextBuildingTest.flow", "BasicStaticFlowCompiler_testApplicationContextBuilding2" );
		Assert.isInstanceOf( code2.locator.BasicStaticFlowCompiler_testApplicationContextBuilding2, hex.mock.MockApplicationContext );
		Assert.equals( "Hola Mundo", code1.locator.test );
		
		//Parallel duplicated code generations and contexts are not the same
		Assert.notEquals( code1, code2 );
		Assert.notEquals( code1.applicationContext, code2.applicationContext );
		Assert.notEquals( code1.locator.BasicStaticFlowCompiler_testApplicationContextBuilding1, code2.locator.BasicStaticFlowCompiler_testApplicationContextBuilding2 );
		
		//Extended code generation uses the same application context
		var code3 = BasicStaticFlowCompiler.extend( code2, "context/flow/simpleInstanceWithoutArguments.flow", "BasicStaticFlowCompiler_testApplicationContextBuilding2" );
		Assert.notEquals( code2, code3 );
		Assert.equals( code2.applicationContext, code3.applicationContext );
		Assert.equals( code2.locator.BasicStaticFlowCompiler_testApplicationContextBuilding2, code3.locator.BasicStaticFlowCompiler_testApplicationContextBuilding2 );
	
		//Compare assemblers
		Assert.equals( code1.applicationAssembler, code2.applicationAssembler );
		Assert.equals( code1.applicationAssembler, code3.applicationAssembler );
		Assert.equals( code2.applicationAssembler, code3.applicationAssembler );
	}
	
	@Test( "test simple method call" )
	public function testSimpleMethodCall() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/simpleMethodCall.flow", "BasicStaticFlowCompiler_testSimpleMethodCall" );
		code.execute();

		Assert.isInstanceOf( code.locator.caller, MockCaller );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments );
	}
	
	@Test( "test method call with type params" )
	public function testCallWithTypeParams() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/methodCallWithTypeParams.flow", "BasicStaticFlowCompiler_testCallWithTypeParams" );
		code.execute();

		Assert.isInstanceOf( code.locator.caller, MockCaller );
		Assert.equals( 3, MockCaller.passedArray.length );
	}
	
	@Test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/multipleInstancesWithMethodCall.flow", "BasicStaticFlowCompiler_testBuildingMultipleInstancesWithMethodCall" );
		code.execute();

		Assert.equals( 30, code.locator.rectSize.x );
		Assert.equals( 40, code.locator.rectSize.y );

		Assert.equals( 10, code.locator.rectPosition.x );
		Assert.equals( 20, code.locator.rectPosition.y );

		Assert.isInstanceOf( code.locator.rect, MockRectangle );
		Assert.equals( 10, code.locator.rect.x );
		Assert.equals( 20, code.locator.rect.y );
		Assert.equals( 30, code.locator.rect.width );
		Assert.equals( 40, code.locator.rect.height );

		Assert.isInstanceOf( code.locator.anotherRect, MockRectangle );
		Assert.equals( 0, code.locator.anotherRect.x );
		Assert.equals( 0, code.locator.anotherRect.y );
		Assert.equals( 0, code.locator.anotherRect.width );
		Assert.equals( 0, code.locator.anotherRect.height );
	}
	
	@Test( "test building instance with static method" )
	public function testBuildingInstanceWithStaticMethod() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/instanceWithStaticMethod.flow", "BasicStaticFlowCompiler_testBuildingInstanceWithStaticMethod" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.service, MockServiceProvider );
		Assert.equals( "http://localhost/amfphp/gateway.php", code.locator.service.getGateway() );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway() );
	}
	
	@Test( "test building instance with static method and arguments" )
	public function testBuildingInstanceWithStaticMethodAndArguments() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/instanceWithStaticMethodAndArguments.flow", "BasicStaticFlowCompiler_testBuildingInstanceWithStaticMethodAndArguments" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.rect, MockRectangle );
		Assert.equals( 10, code.locator.rect.x );
		Assert.equals( 20, code.locator.rect.y );
		Assert.equals( 30, code.locator.rect.width );
		Assert.equals( 40, code.locator.rect.height );
	}
	
	@Test( "test building instance with static method and factory method" )
	public function testBuildingInstanceWithStaticMethodAndFactoryMethod() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/instanceWithStaticMethodAndFactoryMethod.flow", "BasicStaticFlowCompiler_testBuildingInstanceWithStaticMethodAndFactoryMethod" );
		code.execute();
		
		Assert.equals( 10, code.locator.point.x );
		Assert.equals( 20, code.locator.point.y );
	}
	
	@Test( "test 'injector-creation' attribute" )
	public function testInjectorCreationAttribute() : Void
	{
		var injector = this._applicationAssembler.getApplicationContext( "BasicStaticFlowCompiler_testInjectorCreationAttribute", ApplicationContext ).getCoreFactory().getInjector();
		injector.mapToValue( String, 'hola mundo' );
		
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/injectorCreationAttribute.flow", "BasicStaticFlowCompiler_testInjectorCreationAttribute" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClassWithInjectedProperty );
		Assert.equals( "hola mundo", code.locator.instance.property );
		Assert.isTrue( code.locator.instance.postConstructWasCalled );
	}
	
	@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		var injector = this._applicationAssembler.getApplicationContext( "BasicStaticFlowCompiler_testInjectIntoAttribute", ApplicationContext ).getCoreFactory().getInjector();
		injector.mapToValue( String, 'hola mundo' );
		
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/injectIntoAttribute.flow", "BasicStaticFlowCompiler_testInjectIntoAttribute" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClassWithInjectedProperty );
		Assert.equals( "hola mundo", code.locator.instance.property );
		Assert.isTrue( code.locator.instance.postConstructWasCalled );
	}
	
	@Test( "test building XML without parser class" )
	public function testBuildingXMLWithoutParserClass() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/xmlWithoutParserClass.flow", "BasicStaticFlowCompiler_testBuildingXMLWithoutParserClass" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.fruits, Xml );
	}
	
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/xmlWithParserClass.flow", "BasicStaticFlowCompiler_testBuildingXMLWithParserClass" );
		code.execute();

		Assert.equals( 3, code.locator.fruits.length );

		var orange = code.locator.fruits[0];
		var apple = code.locator.fruits[1];
		var banana = code.locator.fruits[2];

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}
	
	@Test( "test building Arrays" )
	public function testBuildingArrays() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/arrayFilledWithReferences.flow", "BasicStaticFlowCompiler_testBuildingArrays" );
		code.execute();
		
		Assert.equals( 2, code.locator.text.length );
		Assert.equals( "hello", code.locator.text[ 0 ] );
		Assert.equals( "world", code.locator.text[ 1 ] );

		Assert.equals( 0, code.locator.empty.length );

		Assert.equals( 3, code.locator.fruits.length, "" );

		var orange 	= code.locator.fruits[0];
		var apple 	= code.locator.fruits[1];
		var banana 	= code.locator.fruits[2];

		Assert.equals( "orange", orange.toString()  );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}
	
	@Test( "test building Map filled with references" )
	public function testBuildingMapFilledWithReferences() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/hashmapFilledWithReferences.flow", "BasicStaticFlowCompiler_testBuildingMapFilledWithReferences" );
		code.execute();

		var fruits = code.locator.fruits;
		Assert.isNotNull( fruits );

		var stubKey = code.locator.stubKey;
		Assert.isNotNull( stubKey );

		var orange 	= code.locator.fruits.get( '0' );
		var apple 	= code.locator.fruits.get( 1 );
		var banana 	= code.locator.fruits.get( stubKey );

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}
	
	@Test( "test building HashMap with map-type" )
	public function testBuildingHashMapWithMapType() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/hashmapWithMapType.flow", "BasicStaticFlowCompiler_testBuildingHashMapWithMapType" );
		code.execute();

		Assert.isNotNull( code.locator.fruits );

		var orange 	= code.locator.fruits.get( '0' );
		var apple 	= code.locator.fruits.get( '1' );

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		
		var map = code.applicationContext.getInjector().getInstanceWithClassName( "hex.collection.HashMap<String,hex.mock.MockFruitVO>", "fruits" );
		Assert.equals( code.locator.fruits, map );
	}
	
	@Test( "test map-type attribute with Array" )
	public function testMapTypeWithArray() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testMapTypeWithArray.flow", "BasicStaticFlowCompiler_testMapTypeWithArray" );
		code.execute();
		
		var intCollection = code.applicationContext.getInjector().getInstanceWithClassName( "Array<Int>", "intCollection" );
		var uintCollection = code.applicationContext.getInjector().getInstanceWithClassName( "Array<UInt>", "intCollection" );
		var stringCollection = code.applicationContext.getInjector().getInstanceWithClassName( "Array<String>", "stringCollection" );
		
		Assert.isInstanceOf( intCollection, Array );
		Assert.isInstanceOf( uintCollection, Array );
		Assert.isInstanceOf( stringCollection, Array );
		
		Assert.equals( intCollection, uintCollection );
		Assert.notEquals( intCollection, stringCollection );
	}
	
	@Test( "test map-type attribute with instance" )
	public function testMapTypeWithInstance() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/testMapTypeWithInstance.flow", "BasicStaticFlowCompiler_testMapTypeWithInstance" );
		code.execute();
		
		var intInstance = code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<Int>", "intInstance" );
		var uintInstance = code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<UInt>", "intInstance" );
		var stringInstance = code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<String>", "stringInstance" );

		Assert.isInstanceOf( intInstance, MockClassWithGeneric );
		Assert.isInstanceOf( uintInstance, MockClassWithGeneric );
		Assert.isInstanceOf( stringInstance, MockClassWithGeneric );
		
		Assert.equals( intInstance, uintInstance );
		Assert.notEquals( intInstance, stringInstance );
	}
	
	@Test( "test building class reference" )
	public function testBuildingClassReference() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/classReference.flow", "BasicStaticFlowCompiler_testBuildingClassReference" );
		code.execute();

		Assert.isInstanceOf( code.locator.RectangleClass, Class );
		Assert.isInstanceOf( Type.createInstance( code.locator.RectangleClass, [] ), MockRectangle );

		Assert.isInstanceOf( code.locator.classContainer.AnotherRectangleClass, Class );
		Assert.isInstanceOf( Type.createInstance( code.locator.classContainer.AnotherRectangleClass, [] ), MockRectangle );

		Assert.equals( code.locator.RectangleClass, code.locator.classContainer.AnotherRectangleClass );
	}
	
	@Test( "test static-ref" )
	public function testStaticRef() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/staticRef.flow", "BasicStaticFlowCompiler_testStaticRef" );
		code.execute();

		Assert.equals( code.locator.constant, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref property" )
	public function testStaticProperty() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/staticRefProperty.flow", "BasicStaticFlowCompiler_testStaticProperty" );
		code.execute();

		Assert.equals( MockClass.MESSAGE_TYPE, code.locator.object.property );
		Assert.equals( MockClass, code.locator.object2.property );
	}
	
	@Test( "test static-ref argument" )
	public function testStaticArgument() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/staticRefArgument.flow", "BasicStaticFlowCompiler_testStaticArgument" );
		code.execute();

		Assert.equals( code.locator.instance.constant, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref argument on method-call" )
	public function testStaticArgumentOnMethodCall() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/staticRefArgumentOnMethodCall.flow", "BasicStaticFlowCompiler_testStaticArgumentOnMethodCall" );
		code.execute();

		Assert.equals( MockMethodCaller.staticVar, code.locator.instance.argument );
	}
	
	@Test( "test map-type attribute" )
	public function testMapTypeAttribute() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/mapTypeAttribute.flow", "BasicStaticFlowCompiler_testMapTypeAttribute" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClass );
		Assert.isInstanceOf( code.locator.instance, IMockInterface );
		Assert.equals( code.locator.instance, code.applicationContext.getInjector().getInstance( IMockInterface, "instance" ) );
	}
	
	@Test( "test multi map-type attributes" )
	public function testMultiMapTypeAttributes() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/multiMapTypeAttributes.flow", "BasicStaticFlowCompiler_testMultiMapTypeAttributes" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClass );
		Assert.isInstanceOf( code.locator.instance, IMockInterface );
		Assert.isInstanceOf( code.locator.instance, IAnotherMockInterface );
		
		Assert.equals( code.locator.instance, code.applicationContext.getInjector().getInstance( IMockInterface, "instance" ) );
		Assert.equals( code.locator.instance, code.applicationContext.getInjector().getInstance( IAnotherMockInterface, "instance" ) );
	}
	
	@Test( "test building Map with class reference" )
	public function testBuildingMapWithClassReference() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/hashmapWithClassReference.flow", "BasicStaticFlowCompiler_testBuildingMapWithClassReference" );
		code.execute();

		Assert.equals( IMockInterface, code.locator.map.getKeys()[ 0 ] );
		Assert.equals( MockClass, code.locator.map.get( IMockInterface ) );
	}
	
	//TODO implement
	/*@Ignore( "test target sub property" )
	public function testTargetSubProperty() : Void
	{
		this._applicationAssembler = BasicFlowCompiler.compile( "context/flow/targetSubProperty.flow" );

		var mockObject : MockObjectWithRegtangleProperty = this._getCoreFactory().locate( "mockObject" );
		Assert.isInstanceOf( mockObject, MockObjectWithRegtangleProperty );
		Assert.equals( 1.5, mockObject.rectangle.x );
	}*/
	
	@Test( "test file preprocessor with flow file" )
	public function testFilePreprocessorWithFlowFile() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/preprocessor.flow", "BasicStaticFlowCompiler_testFilePreprocessorWithFlowFile", 
															[	"hello" 		=> "bonjour",
																"contextName" 	=> 'applicationContext',
																"context" 		=> 'name="${contextName}"',
																"node" 			=> 'message = "${hello}"' ] );
		code.execute();
		
		Assert.equals( "bonjour", code.locator.message, "message value should equal 'bonjour'" );
	}
	
	@Test( "test if attribute" )
	public function testIfAttribute() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/ifAttribute.flow", "BasicStaticFlowCompiler_testIfAttribute", null, [ "prodz" => true, "testing" => false, "releasing" => false ] );
		code.execute();
		
		Assert.equals( "hello prod", code.locator.message, "message value should equal 'hello prod'" );
	}
	
	@Test( "test include with if attribute" )
	public function testIncludeWithIfAttribute() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/includeWithIfAttribute.flow", "BasicStaticFlowCompiler_testIncludeWithIfAttribute", null, [ "prodz" => true, "testing" => false, "releasing" => false ] );
		code.execute();
		
		Assert.equals( "hello prod", code.locator.message, "message value should equal 'hello prod'" );
	}

	@Test( "test include fails with if attribute" )
	public function testIncludeFailsWithIfAttribute() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/includeWithIfAttribute.flow", "BasicStaticFlowCompiler_testIncludeFailsWithIfAttribute", null, [ "prodz" => false, "testing" => true, "releasing" => true ] );
		code.execute();
		
		var coreFactory = this._applicationAssembler.getApplicationContext( "BasicStaticFlowCompiler_testIncludeFailsWithIfAttribute", ApplicationContext ).getCoreFactory();
		Assert.methodCallThrows( NoSuchElementException, coreFactory, coreFactory.locate, [ "message" ], "'NoSuchElementException' should be thrown" );
	}
	
	@Test( "test building mapping configuration" )
	public function testBuildingMappingConfiguration() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._applicationAssembler, "context/flow/mappingConfiguration.flow", "BasicStaticFlowCompiler_testBuildingMappingConfiguration" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.config, MappingConfiguration );

		var injector = new Injector();
		code.locator.config.configure( injector, null );

		Assert.isInstanceOf( injector.getInstance( IMockInterface ), MockClass );
		Assert.isInstanceOf( injector.getInstance( IAnotherMockInterface ), AnotherMockClass );
		Assert.equals( code.locator.instance, injector.getInstance( IAnotherMockInterface ) );
	}
	
	/*@Test( "test trigger method connection" )
	public function testTriggerMethodConnection() : Void
	{
		MockTriggerListener.callbackCount = 0;
		MockTriggerListener.message = '';
		
		this._applicationAssembler = BasicFlowCompiler.compile( "context/flow/trigger.flow" );

		var model : MockModelWithTrigger = this._getCoreFactory().locate( "model" );
		Assert.isInstanceOf( model, MockModelWithTrigger );
		
		model.callbacks.trigger( 'hello world' );
		Assert.equals( 1, MockTriggerListener.callbackCount );
		Assert.equals( 'hello world', MockTriggerListener.message );
	}
	
	@Test( "test Trigger interface connection" )
	public function testTriggerInterfaceConnection() : Void
	{
		MockTriggerListener.callbackCount = 0;
		MockTriggerListener.message = '';
		
		this._applicationAssembler = BasicFlowCompiler.compile( "context/flow/trigger.flow" );

		var model : MockModelWithTrigger = this._getCoreFactory().locate( "model" );
		Assert.isInstanceOf( model, MockModelWithTrigger );
		
		model.trigger.onTrigger( 'hello world' );
		Assert.equals( 1, MockTriggerListener.callbackCount );
		Assert.equals( 'hello world', MockTriggerListener.message );
	}*/
}
