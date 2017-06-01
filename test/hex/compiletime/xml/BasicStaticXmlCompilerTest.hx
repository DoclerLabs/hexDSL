package hex.compiletime.xml;

import hex.core.IApplicationAssembler;
import hex.di.Injector;
import hex.di.mapping.MappingChecker;
import hex.di.mapping.MappingConfiguration;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.error.Exception;
import hex.error.NoSuchElementException;
import hex.mock.AnotherMockClass;
import hex.mock.ArrayOfDependenciesOwner;
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
class BasicStaticXmlCompilerTest 
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/testBuildingString.xml", "BasicStaticXmlCompiler_testBuildingString" );
		
		var locator = code.locator;
		Assert.isNull( locator.s );
		
		code.execute();
		
		Assert.equals( "hello", locator.s );
	}
	
	@Test( "test context reference" )
	public function testContextReference() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/contextReference.xml", "BasicStaticXmlCompiler_testContextReference" );
		code.execute();
		Assert.equals( code.applicationContext, code.locator.contextHolder.context );
	}
	
	@Test( "test building String without context name" )
	public function testBuildingStringWithoutContextName() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/contextWithoutName.xml", "BasicStaticXmlCompiler_testBuildingStringWithoutContextName" );
		code.execute();
		Assert.equals( "hello", code.locator.s );
	}
	
	@Test( "test building String with assembler static property" )
	public function testBuildingStringWithAssemblerStaticProperty() : Void
	{
		BasicStaticXmlCompilerTest.applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticXmlCompiler.compile( BasicStaticXmlCompilerTest.applicationAssembler, "context/xml/testBuildingString.xml", "BasicStaticXmlCompiler_testBuildingStringWithAssemblerStaticProperty" );
		code.execute();
		
		var s : String = BasicStaticXmlCompilerTest.applicationAssembler.getApplicationContext( "BasicStaticXmlCompiler_testBuildingStringWithAssemblerStaticProperty", ApplicationContext ).getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	//Reading twice the same context cannot be tested
	
	@Test( "test overriding context name" )
	public function testOverridingContextName() : Void
	{
		var code1 = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleInstanceWithoutArguments.xml", "BasicStaticXmlCompiler_testOverridingContextName1" );
		var code2 = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleInstanceWithoutArguments.xml", "BasicStaticXmlCompiler_testOverridingContextName2" );
		
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/testBuildingInt.xml", "BasicStaticXmlCompiler_testBuildingInt" );
		code.execute();
		Assert.equals( -3, code.locator.i );
	}
	
	@Test( "test building Hex" )
	public function testBuildingHex() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/testBuildingHex.xml", "BasicStaticXmlCompiler_testBuildingHex" );
		code.execute();
		Assert.equals( 0xFFFFFF, code.locator.i );
	}
	
	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/testBuildingBool.xml", "BasicStaticXmlCompiler_testBuildingBool" );
		code.execute();
		Assert.isTrue( code.locator.b );
	}
	
	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/testBuildingUInt.xml", "BasicStaticXmlCompiler_testBuildingUInt" );
		code.execute();
		Assert.equals( 3, code.locator.i );
	}
	
	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/testBuildingNull.xml", "BasicStaticXmlCompiler_testBuildingNull" );
		code.execute();
		Assert.isNull( code.locator.value );
	}
	
	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/anonymousObject.xml", "BasicStaticXmlCompiler_testBuildingAnonymousObject" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleInstanceWithoutArguments.xml", "BasicStaticXmlCompiler_testBuildingSimpleInstanceWithoutArguments" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClassWithoutArgument );
	}
	
	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleInstanceWithArguments.xml", "BasicStaticXmlCompiler_testBuildingSimpleInstanceWithArguments" );
		
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/multipleInstancesWithArguments.xml", "BasicStaticXmlCompiler_testBuildingMultipleInstancesWithArguments" );
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
		var code = BasicStaticXmlCompiler.compile( applicationAssembler, "context/xml/singleInstanceWithPrimReferences.xml", "BasicStaticXmlCompiler_testBuildingSingleInstanceWithPrimitivesReferences" );
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
		var code = BasicStaticXmlCompiler.compile( applicationAssembler, "context/xml/singleInstanceWithMethodReferences.xml", "BasicStaticXmlCompiler_testBuildingSingleInstanceWithMethodReferences" );
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
	
	@Test( "test assign instance property with references" )
	public function testAssignInstancePropertyWithReference() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticXmlCompiler.compile( applicationAssembler, "context/xml/instancePropertyWithReference.xml", "BasicStaticXmlCompiler_testAssignInstancePropertyWithReference" );
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
		var code = BasicStaticXmlCompiler.compile( applicationAssembler, "context/xml/multipleInstancesWithReferences.xml", "BasicStaticXmlCompiler_testBuildingMultipleInstancesWithReferences" );
		var code2 = BasicStaticXmlCompiler.extend( code, "context/xml/simpleInstanceWithoutArguments.xml" );
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
		var code1 = BasicStaticXmlCompiler.compile( applicationAssembler, "context/xml/applicationContextBuildingTest.xml", "testApplicationContextBuilding1" );
		
		//application assembler reference stored
		Assert.equals( applicationAssembler, code1.applicationAssembler );
		
		//Custom application context is available before code execution
		Assert.equals( code1.applicationContext, code1.locator.testApplicationContextBuilding1 );
		
		//auto-completion is woking on custom applicationContext's class
		Assert.equals( 'test', code1.applicationContext.getTest() );
		Assert.equals( 'test', code1.locator.testApplicationContextBuilding1.getTest() );
		
		//
		code1.execute();

		//
		Assert.isInstanceOf( code1.locator.testApplicationContextBuilding1, hex.mock.MockApplicationContext );
		Assert.equals( "Hola Mundo", code1.locator.test );
		
		//
		var code2 = BasicStaticXmlCompiler.compile( applicationAssembler, "context/xml/applicationContextBuildingTest.xml", "testApplicationContextBuilding2" );
		Assert.isInstanceOf( code2.locator.testApplicationContextBuilding2, hex.mock.MockApplicationContext );
		Assert.equals( "Hola Mundo", code1.locator.test );
		
		//Parallel duplicated code generations and contexts are not the same
		Assert.notEquals( code1, code2 );
		Assert.notEquals( code1.applicationContext, code2.applicationContext );
		Assert.notEquals( code1.locator.testApplicationContextBuilding1, code2.locator.testApplicationContextBuilding2 );
		
		//Extended code generation uses the same application context
		var code3 = BasicStaticXmlCompiler.extend( code2, "context/xml/simpleInstanceWithoutArguments.xml", "testApplicationContextBuilding2" );
		Assert.notEquals( code2, code3 );
		Assert.equals( code2.applicationContext, code3.applicationContext );
		Assert.equals( code2.locator.testApplicationContextBuilding2, code3.locator.testApplicationContextBuilding2 );
	
		//Compare assemblers
		Assert.equals( code1.applicationAssembler, code2.applicationAssembler );
		Assert.equals( code1.applicationAssembler, code3.applicationAssembler );
		Assert.equals( code2.applicationAssembler, code3.applicationAssembler );
	}
	
	@Test( "test simple method call" )
	public function testSimpleMethodCall() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/simpleMethodCall.xml", "BasicStaticXmlCompiler_testSimpleMethodCall" );
		code.execute();

		Assert.isInstanceOf( code.locator.caller, MockCaller );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments );
	}
	
	@Test( "test method call with type params" )
	public function testCallWithTypeParams() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/methodCallWithTypeParams.xml", "BasicStaticXmlCompiler_testCallWithTypeParams" );
		code.execute();

		Assert.isInstanceOf( code.locator.caller, MockCaller );
		Assert.equals( 3, MockCaller.passedArray.length );
	}
	
	@Test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/multipleInstancesWithMethodCall.xml", "BasicStaticXmlCompiler_testBuildingMultipleInstancesWithMethodCall" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/instanceWithStaticMethod.xml", "BasicStaticXmlCompiler_testBuildingInstanceWithStaticMethod" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.service, MockServiceProvider );
		Assert.equals( "http://localhost/amfphp/gateway.php", code.locator.service.getGateway() );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway() );
	}
	
	@Test( "test building instance with static method and arguments" )
	public function testBuildingInstanceWithStaticMethodAndArguments() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/instanceWithStaticMethodAndArguments.xml", "BasicStaticXmlCompiler_testBuildingInstanceWithStaticMethodAndArguments" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/instanceWithStaticMethodAndFactoryMethod.xml", "BasicStaticXmlCompiler_testBuildingInstanceWithStaticMethodAndFactoryMethod" );
		code.execute();
		
		Assert.equals( 10, code.locator.point.x );
		Assert.equals( 20, code.locator.point.y );
	}
	
	@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/injectIntoAttribute.xml", "BasicStaticXmlCompiler_testInjectIntoAttribute" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClassWithInjectedProperty );
		Assert.equals( "hola mundo", code.locator.instance.property );
		Assert.isTrue( code.locator.instance.postConstructWasCalled );
	}
	
	@Test( "test building XML without parser class" )
	public function testBuildingXMLWithoutParserClass() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/xmlWithoutParserClass.xml", "BasicStaticXmlCompiler_testBuildingXMLWithoutParserClass" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.fruits, Xml );
	}
	
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/xmlWithParserClass.xml", "BasicStaticXmlCompiler_testBuildingXMLWithParserClass" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/arrayFilledWithReferences.xml", "BasicStaticXmlCompiler_testBuildingArrays" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/hashmapFilledWithReferences.xml", "BasicStaticXmlCompiler_testBuildingMapFilledWithReferences" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/hashmapWithMapType.xml", "BasicStaticXmlCompiler_testBuildingHashMapWithMapType" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/testMapTypeWithArray.xml", "BasicStaticXmlCompiler_testMapTypeWithArray" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/testMapTypeWithInstance.xml", "BasicStaticXmlCompiler_testMapTypeWithInstance" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/classReference.xml", "BasicStaticXmlCompiler_testBuildingClassReference" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/staticRef.xml", "BasicStaticXmlCompiler_testStaticRef" );
		code.execute();

		Assert.equals( code.locator.constant, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref property" )
	public function testStaticProperty() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/staticRefProperty.xml", "BasicStaticXmlCompiler_testStaticProperty" );
		code.execute();

		Assert.equals( MockClass.MESSAGE_TYPE, code.locator.object.property );
		Assert.equals( MockClass, code.locator.object2.property );
	}
	
	@Test( "test static-ref argument" )
	public function testStaticArgument() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/staticRefArgument.xml", "BasicStaticXmlCompiler_testStaticArgument" );
		code.execute();

		Assert.equals( code.locator.instance.constant, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref argument on method-call" )
	public function testStaticArgumentOnMethodCall() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/staticRefArgumentOnMethodCall.xml", "BasicStaticXmlCompiler_testStaticArgumentOnMethodCall" );
		code.execute();

		Assert.equals( MockMethodCaller.staticVar, code.locator.instance.argument );
	}
	
	@Test( "test map-type attribute" )
	public function testMapTypeAttribute() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/mapTypeAttribute.xml", "BasicStaticXmlCompiler_testMapTypeAttribute" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClass );
		Assert.isInstanceOf( code.locator.instance, IMockInterface );
		Assert.equals( code.locator.instance, code.applicationContext.getInjector().getInstance( IMockInterface, "instance" ) );
	}
	
	@Test( "test multi map-type attributes" )
	public function testMultiMapTypeAttributes() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/multiMapTypeAttributes.xml", "BasicStaticXmlCompiler_testMultiMapTypeAttributes" );
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
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/hashmapWithClassReference.xml", "BasicStaticXmlCompiler_testBuildingMapWithClassReference" );
		code.execute();

		Assert.equals( IMockInterface, code.locator.map.getKeys()[ 0 ] );
		Assert.equals( MockClass, code.locator.map.get( IMockInterface ) );
	}
	
	//TODO implement
	/*@Ignore( "test target sub property" )
	public function testTargetSubProperty() : Void
	{
		this._applicationAssembler = BasicFlowCompiler.compile( "context/xml/targetSubProperty.xml" );

		var mockObject : MockObjectWithRegtangleProperty = this._getCoreFactory().locate( "mockObject" );
		Assert.isInstanceOf( mockObject, MockObjectWithRegtangleProperty );
		Assert.equals( 1.5, mockObject.rectangle.x );
	}*/
	
	@Test( "test if attribute" )
	public function testIfAttribute() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/static/ifAttribute.xml", "BasicStaticXmlCompiler_testIfAttribute", null, [ "prodz2" => true, "testing2" => false, "releasing2" => false ] );
		code.execute();
		
		Assert.equals( "hello prod", code.locator.message );
	}
	
	@Test( "test include with if attribute" )
	public function testIncludeWithIfAttribute() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/static/includeWithIfAttribute.xml", "BasicStaticXmlCompiler_testIncludeWithIfAttribute", null, [ "prodz2" => true, "testing2" => false, "releasing2" => false ] );
		code.execute();
		
		Assert.equals( "hello prod", code.locator.message );
	}

	@Test( "test include fails with if attribute" )
	public function testIncludeFailsWithIfAttribute() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/static/includeWithIfAttribute.xml", "BasicStaticXmlCompiler_testIncludeFailsWithIfAttribute", null, [ "prodz2" => false, "testing2" => true, "releasing2" => true ] );
		code.execute();
		
		var coreFactory = this._applicationAssembler.getApplicationContext( "BasicStaticXmlCompiler_testIncludeFailsWithIfAttribute", ApplicationContext ).getCoreFactory();
		Assert.methodCallThrows( NoSuchElementException, coreFactory, coreFactory.locate, [ "message" ], "'NoSuchElementException' should be thrown" );
	}
	
	@Test( "test file preprocessor with Xml file" )
	public function testFilePreprocessorWithXmlFile() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/preprocessor.xml", "BasicStaticXmlCompiler_testFilePreprocessorWithXmlFile", 
															[	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] );
		code.execute();
		
		Assert.equals( "bonjour", code.locator.message, "message value should equal 'bonjour'" );
	}
	
	@Test( "test file preprocessor with Xml file and include" )
	public function testFilePreprocessorWithXmlFileAndInclude() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/preprocessorWithInclude.xml", "BasicStaticXmlCompiler_testFilePreprocessorWithXmlFileAndInclude", 
																				[	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] );
		code.execute();
		
		try
        {
			Assert.equals( "bonjour", code.locator.message, "message value should equal 'bonjour'" );
		}
		catch ( e : Exception )
        {
            Assert.fail( e.message, "Exception on this._builderFactory.getCoreFactory().locate( \"message\" ) call" );
        }
	}
	
	@Test( "test building mapping configuration" )
	public function testBuildingMappingConfiguration() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/mappingConfiguration.xml", "BasicStaticXmlCompiler_testBuildingMappingConfiguration" );
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
		
		this._applicationAssembler = BasicFlowCompiler.compile( "context/xml/trigger.xml" );

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
		
		this._applicationAssembler = BasicFlowCompiler.compile( "context/xml/trigger.xml" );

		var model : MockModelWithTrigger = this._getCoreFactory().locate( "model" );
		Assert.isInstanceOf( model, MockModelWithTrigger );
		
		model.trigger.onTrigger( 'hello world' );
		Assert.equals( 1, MockTriggerListener.callbackCount );
		Assert.equals( 'hello world', MockTriggerListener.message );
	}*/
	
	@Test( "test parsing twice" )
	public function testParsingTwice() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/parsingOnce.xml", "BasicStaticXmlCompiler_testParsingTwice" );
		var code2 = BasicStaticXmlCompiler.extend( code, "context/xml/parsingTwice.xml" );

		code.execute();
		Assert.isInstanceOf( code.locator.rect0, MockRectangle );
		Assert.equals( 10, code.locator.rect0.x );
		Assert.equals( 20, code.locator.rect0.y );
		Assert.equals( 30, code.locator.rect0.width );
		Assert.equals( 40, code.locator.rect0.height );

		code2.execute();
		Assert.isInstanceOf( code2.locator.rect1, MockRectangle );
		Assert.equals( 50, code2.locator.rect1.x );
		Assert.equals( 60, code2.locator.rect1.y );
		Assert.equals( 70, code2.locator.rect1.width );
		Assert.equals( 40, code2.locator.rect1.height );
	}
	
	@Test( "test build domain" )
	public function testBuildDomain() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/buildDomain.xml", "BasicStaticXmlCompiler_testBuildDomain" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.applicationDomain, Domain );
	}
	
	@Test( "test recursive static calls" )
	public function testRecursiveStaticCalls() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/instanceWithStaticMethodAndArguments.xml", "BasicStaticXmlCompiler_testRecursiveStaticCalls" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.rect, MockRectangle );
		Assert.equals( 10, code.locator.rect.x );
		Assert.equals( 20, code.locator.rect.y );
		Assert.equals( 30, code.locator.rect.width );
		Assert.equals( 40, code.locator.rect.height );
		
		var code2 = BasicStaticXmlCompiler.extend( code, "context/xml/testRecursiveStaticCalls.xml" );
		code2.execute();
		
		Assert.isInstanceOf( code2.locator.rect2, MockRectangle );
		Assert.equals( 10, code2.locator.rect2.x );
		Assert.equals( 20, code2.locator.rect2.y );
		Assert.equals( 30, code2.locator.rect2.width );
		Assert.equals( 40, code2.locator.rect2.height );
	}
	
	@Test( "test runtime arguments" )
	public function testRuntimeArguments() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/runtimeArguments.xml", "BasicStaticXmlCompiler_testRuntimeArguments" );
		code.execute( { x:10, y: 20, p: new hex.structures.Point( 30, 40 ) } );
		
		Assert.isInstanceOf( code.locator.size, Size );
		Assert.equals( 10, code.locator.size.width );
		Assert.equals( 20, code.locator.size.height );
		
		Assert.isInstanceOf( code.locator.anotherSize, Size );
		Assert.equals( 30, code.locator.anotherSize.width );
		Assert.equals( 40, code.locator.anotherSize.height );
	}
	
	/*@Test( "test runtime context" )
	public function testRuntimeContext() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/runtimeContext.xml" );
		code.execute( {contextName:"BasicStaticXmlCompiler_testRuntimeContext"} );
		code.execute( {contextName:"BasicStaticXmlCompiler_testRuntimeContext2" } );
	}*/
	
	@Test( "test dependencies checking" )
	public function testDependenciesChecking() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/static/dependencies.xml", "BasicStaticXmlCompiler_testDependenciesChecking" );
		code.execute();
	}
	
	@Test( "test array of dependencies checking" )
	public function testArrayOfDependenciesChecking() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/static/arrayOfDependencies.xml", "BasicStaticXmlCompiler_testArrayOfDependenciesChecking" );
		code.execute();

		Assert.isTrue( MappingChecker.match( ArrayOfDependenciesOwner, code.locator.mappings1 ) );
		Assert.isTrue( MappingChecker.match( ArrayOfDependenciesOwner, code.locator.mappings2 ) );
		Assert.deepEquals( code.locator.mappings1, code.locator.mappings2 );
	}
	
	@Test( "test mixed dependencies checking" )
	public function testMixedDependenciesChecking() : Void
	{
		var code = BasicStaticXmlCompiler.compile( this._applicationAssembler, "context/xml/static/mixedDependencies.xml", "BasicStaticFlowCompiler_testMixedDependenciesChecking" );
		code.execute();
	}
}