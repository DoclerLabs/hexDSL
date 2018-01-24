package hex.compiletime.flow;

import hex.compiletime.flow.BasicStaticFlowCompiler;
import hex.core.IApplicationAssembler;
import hex.di.Injector;
import hex.di.mapping.MappingChecker;
import hex.di.mapping.MappingConfiguration;
import hex.domain.ApplicationDomainDispatcher;
import hex.domain.Domain;
import hex.mock.AnotherMockClass;
import hex.mock.ArrayOfDependenciesOwner;
import hex.mock.IAnotherMockInterface;
import hex.mock.IMockInterface;
import hex.mock.LazyClass;
import hex.mock.LazyProvider;
import hex.mock.MockCaller;
import hex.mock.MockChat;
import hex.mock.MockClass;
import hex.mock.MockClassWithGeneric;
import hex.mock.MockClassWithInjectedProperty;
import hex.mock.MockClassWithoutArgument;
import hex.mock.MockClassWithProperty;
import hex.mock.MockMethodCaller;
import hex.mock.MockModelWithTrigger;
import hex.mock.MockObjectWithRegtangleProperty;
import hex.mock.MockProxy;
import hex.mock.MockReceiver;
import hex.mock.MockRectangle;
import hex.mock.MockServiceProvider;
import hex.mock.MockTriggerListener;
import hex.mock.Sample;
import hex.runtime.ApplicationAssembler;
import hex.structures.Point;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BasicStaticFlowCompilerTest 
{
	var _myApplicationAssembler : IApplicationAssembler;
	static var applicationAssembler : IApplicationAssembler;

	@Before
	public function setUp() : Void
	{
		this._myApplicationAssembler = new ApplicationAssembler();
	}
	
	@After
	public function tearDown() : Void
	{
		ApplicationDomainDispatcher.release();
		this._myApplicationAssembler.release();
	}
	
	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/primitives/string.flow", "BasicStaticFlowCompiler_testBuildingString" );
		
		var locator = code.locator;
		Assert.isNull( locator.s );
		
		code.execute();
		
		Assert.equals( "hello", locator.s );
	}
	
	@Test( "test context reference" )
	public function testContextReference() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/contextReference.flow", "BasicStaticFlowCompiler_testContextReference" );
		code.execute();
		Assert.equals( code.applicationContext, code.locator.contextHolder.context );
	}
	
	@Test( "test building String without context name" )
	public function testBuildingStringWithoutContextName() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/contextWithoutName.flow", "BasicStaticFlowCompiler_testBuildingStringWithoutContextName" );
		code.execute();
		Assert.equals( "hello", code.locator.s );
	}
	
	@Test( "test building String with assembler static property" )
	public function testBuildingStringWithAssemblerStaticProperty() : Void
	{
		BasicStaticFlowCompilerTest.applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticFlowCompiler.compile( BasicStaticFlowCompilerTest.applicationAssembler, "context/flow/primitives/string.flow", "BasicStaticFlowCompiler_testBuildingStringWithAssemblerStaticProperty" );
		code.execute();
		
		Assert.equals( BasicStaticFlowCompilerTest.applicationAssembler, code.applicationAssembler );
		Assert.equals( "hello", code.locator.s );
	}
	
	@Test( "test read twice the same context" )
	public function testReadTwiceTheSameContext() : Void
	{
		var code1 = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow", "BasicStaticFlowCompiler_testReadTwiceTheSameContext" );
		code1.execute();
		
		var code2 = code1.clone( new ApplicationAssembler() );
		code2.execute();

		Assert.isInstanceOf( code1.locator.instance, MockClassWithoutArgument );
		Assert.isInstanceOf( code2.locator.instance, MockClassWithoutArgument );
		
		Assert.notEquals( code1.locator.instance, code2.locator.instance );
	}
	
	@Test( "test overriding context name" )
	public function testOverridingContextName() : Void
	{
		var code1 = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow", "BasicStaticFlowCompiler_testOverridingContextName1" );
		var code2 = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow", "BasicStaticFlowCompiler_testOverridingContextName2" );
		
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/primitives/int.flow", "BasicStaticFlowCompiler_testBuildingInt" );
		code.execute();
		Assert.equals( -3, code.locator.i );
	}
	
	@Test( "test building Hex" )
	public function testBuildingHex() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/primitives/hex.flow", "BasicStaticFlowCompiler_testBuildingHex" );
		code.execute();
		Assert.equals( 0xFFFFFF, code.locator.i );
	}
	
	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/primitives/bool.flow", "BasicStaticFlowCompiler_testBuildingBool" );
		code.execute();
		Assert.isTrue( code.locator.b );
	}
	
	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/primitives/uint.flow", "BasicStaticFlowCompiler_testBuildingUInt" );
		code.execute();
		Assert.equals( 3, code.locator.i );
	}
	
	@Test( "test building Float" )
	public function testBuildingFloat() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/primitives/float.flow", "BasicStaticFlowCompiler_testBuildingFloat" );
		code.execute();
		Assert.equals( -12.5, code.locator.f );
		Assert.equals( 13.0, code.locator.f2 );
	}
	
	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/primitives/null.flow", "BasicStaticFlowCompiler_testBuildingNull" );
		code.execute();
		Assert.isNull( code.locator.value );
	}
	
	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/anonymousObject.flow", "BasicStaticFlowCompiler_testBuildingAnonymousObject" );
		code.execute();
		
		//TODO make structure with typed properties
		var obj = code.locator.obj;

		Assert.equals( "Francis", obj.name );
		Assert.equals( 44, obj.age );
		Assert.equals( 1.75, obj.height );
		Assert.isTrue( obj.isWorking );
		Assert.isFalse( obj.isSleeping );
		Assert.deepEquals( [1, 2], code.locator.obj.data );
		
		Assert.isNotNull( code.locator.emptyObj );
		
	}
	
	@Test( "test building simple instance without arguments" )
	public function testBuildingSimpleInstanceWithoutArguments() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/simpleInstanceWithoutArguments.flow", "BasicStaticFlowCompiler_testBuildingSimpleInstanceWithoutArguments" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClassWithoutArgument );
	}
	
	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/simpleInstanceWithArguments.flow", "BasicStaticFlowCompiler_testBuildingSimpleInstanceWithArguments" );
		
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/multipleInstancesWithArguments.flow", "BasicStaticFlowCompiler_testBuildingMultipleInstancesWithArguments" );
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
		var code2 = BasicStaticFlowCompiler.extend( applicationAssembler, code, "context/flow/simpleInstanceWithoutArguments.flow" );
		var code3 = BasicStaticFlowCompiler.extend( applicationAssembler, code, "context/flow/multipleInstancesWithReferencesReferenced.flow" );
		
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
		var code3 = BasicStaticFlowCompiler.extend( applicationAssembler, code2, "context/flow/simpleInstanceWithoutArguments.flow", "BasicStaticFlowCompiler_testApplicationContextBuilding2" );
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/simpleMethodCall.flow", "BasicStaticFlowCompiler_testSimpleMethodCall" );
		code.execute();

		Assert.isInstanceOf( code.locator.caller, MockCaller );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments );
	}
	
	@Test( "test method call with type params" )
	public function testCallWithTypeParams() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/methodCallWithTypeParams.flow", "BasicStaticFlowCompiler_testCallWithTypeParams" );
		code.execute();

		Assert.isInstanceOf( code.locator.caller, MockCaller );
		Assert.equals( 3, MockCaller.passedArray.length );
	}
	
	@Test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/multipleInstancesWithMethodCall.flow", "BasicStaticFlowCompiler_testBuildingMultipleInstancesWithMethodCall" );
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/instanceWithStaticMethod.flow", "BasicStaticFlowCompiler_testBuildingInstanceWithStaticMethod" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.service, MockServiceProvider );
		Assert.equals( "http://localhost/amfphp/gateway.php", code.locator.service.getGateway() );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway() );
	}

	@Test( "test static method on class without classpath" )
	public function testStaticMethodOnClassWitoutClasspath() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/instanceWithStaticMethod.flow", "BasicStaticFlowCompiler_testStaticMethodOnClassWitoutClasspath" );
		code.execute();

		Assert.isInstanceOf( code.locator.random, Float );
	}
	
	@Test( "test building instance with static method and arguments" )
	public function testBuildingInstanceWithStaticMethodAndArguments() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/instanceWithStaticMethodAndArguments.flow", "BasicStaticFlowCompiler_testBuildingInstanceWithStaticMethodAndArguments" );
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/instanceWithStaticMethodAndFactoryMethod.flow", "BasicStaticFlowCompiler_testBuildingInstanceWithStaticMethodAndFactoryMethod" );
		code.execute();
		
		Assert.equals( 10, code.locator.point.x );
		Assert.equals( 20, code.locator.point.y );
	}
	
	@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/injectIntoAttribute.flow", "BasicStaticFlowCompiler_testInjectIntoAttribute" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClassWithInjectedProperty );
		Assert.equals( "hola mundo", code.locator.instance.property );
		Assert.isTrue( code.locator.instance.postConstructWasCalled );
	}
	
	@Test( "test building XML without parser class" )
	public function testBuildingXMLWithoutParserClass() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/xmlWithoutParserClass.flow", "BasicStaticFlowCompiler_testBuildingXMLWithoutParserClass" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.fruits, Xml );
	}
	
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/xmlWithParserClass.flow", "BasicStaticFlowCompiler_testBuildingXMLWithParserClass" );
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/arrayFilledWithReferences.flow", "BasicStaticFlowCompiler_testBuildingArrays" );
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/hashmapFilledWithReferences.flow", "BasicStaticFlowCompiler_testBuildingMapFilledWithReferences" );
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/hashmapWithMapType.flow", "BasicStaticFlowCompiler_testBuildingHashMapWithMapType" );
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/mapTypeWithArray.flow", "BasicStaticFlowCompiler_testMapTypeWithArray" );
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/mapTypeWithInstance.flow", "BasicStaticFlowCompiler_testMapTypeWithInstance" );
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/classReference.flow", "BasicStaticFlowCompiler_testBuildingClassReference" );
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/staticRef.flow", "BasicStaticFlowCompiler_testStaticRef" );
		code.execute();

		Assert.equals( code.locator.constant, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref property" )
	public function testStaticProperty() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/staticRefProperty.flow", "BasicStaticFlowCompiler_testStaticProperty" );
		code.execute();

		Assert.equals( MockClass.MESSAGE_TYPE, code.locator.object.property );
		Assert.equals( MockClass, code.locator.object2.property );
	}
	
	@Test( "test static-ref argument" )
	public function testStaticArgument() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/staticRefArgument.flow", "BasicStaticFlowCompiler_testStaticArgument" );
		code.execute();

		Assert.equals( code.locator.instance.constant, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref argument on method-call" )
	public function testStaticArgumentOnMethodCall() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/staticRefArgumentOnMethodCall.flow", "BasicStaticFlowCompiler_testStaticArgumentOnMethodCall" );
		code.execute();

		Assert.equals( MockMethodCaller.staticVar, code.locator.instance.argument );
	}
	
	@Test( "test map-type attribute" )
	public function testMapTypeAttribute() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/mapTypeAttribute.flow", "BasicStaticFlowCompiler_testMapTypeAttribute" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClass );
		Assert.isInstanceOf( code.locator.instance, IMockInterface );
		Assert.equals( code.locator.instance, code.applicationContext.getInjector().getInstance( IMockInterface, "instance" ) );
	
		Assert.isNotNull( code.locator.instance2 );
		Assert.isInstanceOf( code.locator.instance2, MockClass );
		Assert.equals( code.locator.instance2, code.applicationContext.getInjector().getInstanceWithClassName( 'hex.mock.MockModuleWithInternalType.GetInfosInternalTypedef', "instance2" ) );
	}
	
	@Test( "test multi map-type attributes" )
	public function testMultiMapTypeAttributes() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/multiMapTypeAttributes.flow", "BasicStaticFlowCompiler_testMultiMapTypeAttributes" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClass );
		Assert.isInstanceOf( code.locator.instance, IMockInterface );
		Assert.isInstanceOf( code.locator.instance, IAnotherMockInterface );
		
		Assert.equals( code.locator.instance, code.applicationContext.getInjector().getInstance( IMockInterface, "instance" ) );
		Assert.equals( code.locator.instance, code.applicationContext.getInjector().getInstance( IAnotherMockInterface, "instance" ) );
		
		Assert.equals( code.locator.f, code.applicationContext.getInjector().getInstanceWithClassName( "String->String", "f" ) );
		Assert.equals( code.locator.f, code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.MockModuleWithInternalType.FunctionSignature", "f" ) );
	
		Assert.equals( code.locator.f2, code.applicationContext.getInjector().getInstanceWithClassName( "String->String", "f2" ) );
		Assert.equals( code.locator.f2, code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.MockModuleWithInternalType.FunctionSignature", "f2" ) );
		
		Assert.equals( code.locator.f, code.locator.instanceWithSubType.toInject1 );
		Assert.equals( code.locator.f2, code.locator.instanceWithSubType.toInject2 );
		Assert.equals( code.locator.f, code.locator.instanceWithSubType.toInject1b );
		Assert.equals( code.locator.f2, code.locator.instanceWithSubType.toInject2b );
		Assert.equals( code.locator.f, code.locator.instanceWithSubType.toInject1c );
		Assert.equals( code.locator.f2, code.locator.instanceWithSubType.toInject2c );
	}
	
	@Test( "test building Map with class reference" )
	public function testBuildingMapWithClassReference() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/hashmapWithClassReference.flow", "BasicStaticFlowCompiler_testBuildingMapWithClassReference" );
		code.execute();

		Assert.equals( IMockInterface, code.locator.map.getKeys()[ 0 ] );
		Assert.equals( MockClass, code.locator.map.get( IMockInterface ) );
	}
	
	@Test( "test target sub property" )
	public function testTargetSubProperty() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/targetSubProperty.flow", "BasicStaticFlowCompiler_testTargetSubProperty" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.mockObject, MockObjectWithRegtangleProperty );
		Assert.equals( 1.5, code.locator.mockObject.rectangle.x );
	}

	@Test( "test recursive property reference" )
	public function testRecursivePropertyReference() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/propertyReference.flow", "BasicStaticFlowCompiler_testRecursivePropertyReference" );
		code.execute();

		Assert.equals( 'property', code.locator.oClass.property );
		Assert.equals( 'property', code.locator.oDynamic.p );
	}

	@Test( "test recursive property reference to reference" )
	public function testRecursivePropertyReferenceToReference() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/propertyReferenceToReference.flow", "BasicStaticFlowCompiler_testRecursivePropertyReferenceToReference" );
		code.execute();

		Assert.equals( 'property', code.locator.oClass.property );
		Assert.equals( 'property', code.locator.oDynamic.p );
	}
	
	@Test( "test file preprocessor with flow file" )
	public function testFilePreprocessorWithFlowFile() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/preprocessor.flow", "BasicStaticFlowCompiler_testFilePreprocessorWithFlowFile", 
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
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/ifAttribute.flow", "BasicStaticFlowCompiler_testIfAttribute", null, [ "prodz" => true, "testing" => false, "releasing" => false ] );
		code.execute();
		
		Assert.equals( "hello prod", code.locator.message, "message value should equal 'hello prod'" );
	}
	
	@Test( "test include with if attribute" )
	public function testIncludeWithIfAttribute() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/includeWithIfAttribute.flow", "BasicStaticFlowCompiler_testIncludeWithIfAttribute", null, [ "prodz" => true, "testing" => false, "releasing" => false ] );
		code.execute();
		
		Assert.equals( "hello prod", code.locator.message, "message value should equal 'hello prod'" );
	}

	@Test( "test include fails with if attribute" )
	public function testIncludeFailsWithIfAttribute() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/includeWithIfAttribute.flow", "BasicStaticFlowCompiler_testIncludeFailsWithIfAttribute", null, [ "prodz" => false, "testing" => true, "releasing" => true ] );
		code.execute();

		Assert.isFalse( Reflect.hasField(code.locator, "message"), "locator shouldn't have message field" );
	}

	@Test( "test building mapping configuration" )
	public function testBuildingMappingConfiguration() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/mappingConfiguration.flow", "BasicStaticFlowCompiler_testBuildingMappingConfiguration" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.config, MappingConfiguration );

		var injector = new Injector();
		code.locator.config.configure( injector, null );

		Assert.isInstanceOf( injector.getInstance( IMockInterface ), MockClass );
		Assert.isInstanceOf( injector.getInstance( IAnotherMockInterface ), AnotherMockClass );
		Assert.equals( code.locator.instance, injector.getInstance( IAnotherMockInterface ) );
	}
	
	@Test( "test trigger method connection" )
	public function testTriggerMethodConnection() : Void
	{
		MockTriggerListener.callbackCount = 0;
		MockTriggerListener.message = '';
		
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/trigger.flow", "BasicStaticFlowCompiler_testTriggerMethodConnection" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.model, MockModelWithTrigger );
		
		code.locator.model.callbacks.trigger( 'hello world' );
		Assert.equals( 1, MockTriggerListener.callbackCount );
		Assert.equals( 'hello world', MockTriggerListener.message );
	}
	
	@Test( "test Trigger interface connection" )
	public function testTriggerInterfaceConnection() : Void
	{
		MockTriggerListener.callbackCount = 0;
		MockTriggerListener.message = '';
		
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/trigger.flow", "BasicStaticFlowCompiler_testTriggerInterfaceConnection" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.model, MockModelWithTrigger );
		
		code.locator.model.trigger.onTrigger( 'hello world' );
		Assert.equals( 1, MockTriggerListener.callbackCount );
		Assert.equals( 'hello world', MockTriggerListener.message );
	}
	
	@Test( "test build domain" )
	public function testBuildDomain() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/buildDomain.flow", "BasicStaticFlowCompiler_testBuildDomain" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.applicationDomain, Domain );
	}

	@Test( "test recursive static calls" )
	public function testRecursiveStaticCalls() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/instanceWithStaticMethodAndArguments.flow", "BasicStaticFlowCompiler_testRecursiveStaticCalls" );
		code.execute();

		Assert.isInstanceOf( code.locator.rect, MockRectangle );
		Assert.equals( 10, code.locator.rect.x );
		Assert.equals( 20, code.locator.rect.y );
		Assert.equals( 30, code.locator.rect.width );
		Assert.equals( 40, code.locator.rect.height );

		var code2 = BasicStaticFlowCompiler.extend( this._myApplicationAssembler, code, "context/flow/testRecursiveStaticCalls.flow" );
		code2.execute();

		Assert.isInstanceOf( code2.locator.rect2, MockRectangle );
		Assert.equals( 10, code2.locator.rect2.x );
		Assert.equals( 20, code2.locator.rect2.y );
		Assert.equals( 30, code2.locator.rect2.width );
		Assert.equals( 40, code2.locator.rect2.height );
	}

	@Test( "test property on reference node" )
	public function testPropertyOnReferenceNode() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/simpleInstanceWithProperty.flow", "BasicStaticFlowCompiler_testPropertyOnReferenceNode" );
		code.execute();

		Assert.isInstanceOf( code.locator.instance, MockClassWithProperty );
		Assert.equals( "default value", code.locator.instance.property );

		var code2 = BasicStaticFlowCompiler.extend( this._myApplicationAssembler, code, "context/flow/simpleReferenceWithProperty.flow" );
		code2.execute();

		Assert.isInstanceOf( code2.locator.instance, MockClassWithProperty );
		Assert.equals( "new value", code2.locator.instance.property );
	}
	
	@Test( "test runtime arguments" )
	public function testRuntimeArguments() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/runtimeArguments.flow", "BasicStaticFlowCompiler_testRuntimeArguments" );
		code.execute( { x:10, y: 20, p: new Point( 30, 40 ) } );
		
		Assert.isInstanceOf( code.locator.size, Size );
		Assert.equals( 10, code.locator.size.width );
		Assert.equals( 20, code.locator.size.height );
		
		Assert.isInstanceOf( code.locator.anotherSize, Size );
		Assert.equals( 30, code.locator.anotherSize.width );
		Assert.equals( 40, code.locator.anotherSize.height );
	}
	
	@Test( "test array recursivity" )
	public function testArrayRecursivity() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/arrayRecursivity.flow", "BasicStaticFlowCompiler_testArrayRecursivity" );
		code.execute();

		Assert.isInstanceOf( code.locator.test[ 0 ] , Array );
		Assert.isInstanceOf( code.locator.test[ 1 ] , Array );
		Assert.isInstanceOf( code.locator.test[ 2 ] , Array );
		Assert.isInstanceOf( code.locator.test[0][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( code.locator.test[1][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( code.locator.test[2][0], hex.mock.MockClassWithIntGeneric );
		Assert.equals( 1, code.locator.test[0][0].property );
		Assert.equals( 2, code.locator.test[1][0].property );
		Assert.equals( 3, code.locator.test[2][0].property );
		
		var a = code.locator.test[ 3 ];
		Assert.isInstanceOf( a[ 0 ] , hex.mock.MockClassWithIntGeneric );
		Assert.equals( 4, a[ 0 ].property );
		Assert.isInstanceOf( a[ 1 ] , hex.mock.MockClassWithIntGeneric );
		Assert.equals( 5, a[ 1 ].property );
	}
	
	@Test( "test array recursivity with new" )
	public function testArrayRecursivityWithNew() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/arrayRecursivityWithNew.flow", "BasicStaticFlowCompiler_testArrayRecursivityWithNew" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.test[ 0 ] , Array );
		Assert.isInstanceOf( code.locator.test[ 1 ] , Array );
		Assert.isInstanceOf( code.locator.test[ 2 ] , Array );
		Assert.isInstanceOf( code.locator.test[0][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( code.locator.test[1][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( code.locator.test[2][0], hex.mock.MockClassWithIntGeneric );
		Assert.equals( 1, code.locator.test[0][0].property );
		Assert.equals( 2, code.locator.test[1][0].property );
		Assert.equals( 3, code.locator.test[2][0].property );
		
		var a = code.locator.test[ 3 ];
		Assert.isInstanceOf( a[ 0 ] , hex.mock.MockClassWithIntGeneric );
		Assert.equals( 4, a[ 0 ].property );
		Assert.equals( 5, a[ 1 ] );
	}
	
	@Test( "test array recursivity with new mixed with brackets" )
	public function testArrayRecursivityWithNewMixedWithBrackets() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/arrayRecursivityWithNewMixedWithBrackets.flow", "BasicStaticFlowCompiler_testArrayRecursivityWithNewMixedWithBrackets" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.test[ 0 ] , Array );
		Assert.isInstanceOf( code.locator.test[ 1 ] , Array );
		Assert.isInstanceOf( code.locator.test[ 2 ] , Array );
		Assert.isInstanceOf( code.locator.test[0][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( code.locator.test[1][0], hex.mock.MockClassWithIntGeneric );
		Assert.isInstanceOf( code.locator.test[2][0], hex.mock.MockClassWithIntGeneric );
		Assert.equals( 1, code.locator.test[0][0].property );
		Assert.equals( 2, code.locator.test[1][0].property );
		Assert.equals( 3, code.locator.test[2][0].property );
		
		var a = code.locator.test[ 3 ];
		Assert.isInstanceOf( a[ 0 ] , hex.mock.MockClassWithIntGeneric );
		Assert.equals( 4, a[ 0 ].property );
		Assert.equals( 5, a[ 1 ] );
	}
	
	@Test( "test new recursivity" )
	public function testNewRecursivity() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/newRecursivity.flow", "BasicStaticFlowCompiler_testNewRecursivity" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.test, hex.mock.MockContextHolder );
		Assert.isInstanceOf( code.locator.test.context, hex.mock.MockApplicationContext );
	}
	
	@Test( "test dependencies checking" )
	public function testDependenciesChecking() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/dependencies.flow", "BasicStaticFlowCompiler_testDependenciesChecking" );
		code.execute();
	}
	
	@Test( "test array of dependencies checking" )
	public function testArrayOfDependenciesChecking() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/arrayOfDependencies.flow", "BasicStaticFlowCompiler_testArrayOfDependenciesChecking" );
		code.execute();

		Assert.isTrue( MappingChecker.match( ArrayOfDependenciesOwner, code.locator.mappings1 ) );
		Assert.isTrue( MappingChecker.match( ArrayOfDependenciesOwner, code.locator.mappings2 ) );
		Assert.deepEquals( code.locator.mappings1, code.locator.mappings2 );
	}
	
	@Test( "test mixed dependencies checking" )
	public function testMixedDependenciesChecking() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/mixedDependencies.flow", "BasicStaticFlowCompiler_testMixedDependenciesChecking" );
		code.execute();
		
		Assert.equals( "String", code.locator.mapping1.fromType );
		Assert.equals( "test", code.locator.mapping1.toValue );
		Assert.equals( code.locator.s, code.locator.mapping1.toValue );
		
		Assert.equals( "hex.mock.Interface", code.locator.mapping2.fromType );
		Assert.isInstanceOf( code.locator.mapping2.toValue, hex.mock.Clazz );
		Assert.equals( "anotherID", code.locator.mapping2.withName );
		
		Assert.equals( code.locator.mapping2, code.locator.mappings[0] );
		
		var mapping = code.locator.mappings[ 1 ];
		Assert.equals( "hex.mock.Interface", mapping.fromType );
		Assert.equals( hex.mock.Clazz, mapping.toClass );
		Assert.equals( "id", mapping.withName );
		
		var injector = code.locator.owner.getInjector();
		Assert.equals( "test", injector.getInstanceWithClassName( "String" ) );
		Assert.isInstanceOf( injector.getInstanceWithClassName( "hex.mock.Interface", "anotherID" ), hex.mock.Clazz );
		Assert.equals( injector.getInstanceWithClassName( "hex.mock.Interface", "anotherID" ), injector.getInstanceWithClassName( "hex.mock.Interface", "anotherID" ) );
		
		var instance = injector.getInstanceWithClassName( "hex.mock.Interface", "id" );
		Assert.isInstanceOf( instance, hex.mock.Clazz );
		Assert.equals( instance, injector.getInstanceWithClassName( "hex.mock.Interface", "id" ) );
	}
	
	@Test( "test property recursivity" )
	public function testPropertyRecursivity() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/propertyRecursivity.flow", "BasicStaticFlowCompiler_testPropertyRecursivity" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.o1.p, hex.mock.Clazz );
		
		Assert.isInstanceOf( code.locator.o2.p, hex.mock.MockContextHolder );
		Assert.isInstanceOf( code.locator.o2.p.context, hex.mock.MockApplicationContext );
		
		Assert.equals( 10, code.locator.r.width );
		Assert.equals( 20, code.locator.r.height );
	}
	
	@Test( "test add custom parser" )
	public function testAddCustomParser() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/addParser.flow", "BasicStaticFlowCompiler_testAddCustomParser" );
		code.execute();
		
		Assert.equals( 'hello world !', code.locator.s );
		Assert.equals( 11, code.locator.i );
		Assert.equals( 11, code.locator.p.x );
		Assert.equals( 13, code.locator.p.y );
	}
	
	@Test( "test alias primitive" )
	public function testAliasPrimitive() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/aliasPrimitive.flow", "BasicStaticFlowCompiler_aliasPrimitive" );
		code.execute();
		
		Assert.equals( 5, code.locator.value );
		Assert.equals( code.locator.value, code.locator.x );
		
		var i : Int;
		i = code.locator.x;
		Assert.equals( 5, i );
	}
	
	@Test( "test alias instance" )
	public function testAliasInstance() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/aliasInstance.flow", "BasicStaticFlowCompiler_aliasInstance" );
		code.execute();

		var position = code.locator.reference;
		Assert.equals( 1, position.x );
		Assert.equals( 2, position.y );
	}
	
	@Test( "test runtime alias primitive" )
	public function testRuntimeAliasPrimitive() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/runtimeAliasPrimitive.flow", "BasicStaticFlowCompiler_runtimeAliasPrimitive" );
		code.execute( {value: 5} );
		
		Assert.equals( 5, code.locator.x );
		
		var i : Int;
		i = code.locator.x;
		Assert.equals( 5, i );
	}
	
	@Test( "test runtime alias instance" )
	public function testRuntimeAliasInstance() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/runtimeAliasInstance.flow", "BasicStaticFlowCompiler_runtimeAliasInstance" );
		var p = new hex.structures.Point(1, 2);
		code.execute( {p: p} );
		
		Assert.equals( 1, code.locator.position.x );
		Assert.equals( 2, code.locator.position.y );

		Assert.equals( p, code.locator.position );
		Assert.equals( code.locator.position, code.locator.anotherPosition );
	}
	
	@Test( "test Array concat with util" )
	public function testArrayConcatWithUtil() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/arrayConcat.flow", "BasicStaticFlowCompiler_testArrayConcatWithUtil" );
		code.execute();
		Assert.deepEquals( [1,2,3,4,5,6], code.locator.result );
	}
	
	@Test( "test Array concat with runtime parameters" )
	public function testArrayConcatWithRuntimeParameter() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/arrayConcatRuntimeParam.flow", "MixedDslTest_testArrayConcatWithRuntimeParameter" );
		code.execute( { collection:[1, 2, 3] } );
		Assert.deepEquals( [1,2,3,4,5,6], code.locator.result );
	}
	
	#if js
	@Test( "test div selection" )
	public function testDivSelection() : Void
	{
		if ( js.Browser.supported )
		{
			var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/divSelection.flow", "MixedDslTest_testDivSelection" );
			code.execute( { divName: '#console' } );
			Assert.equals( code.locator.div1, code.locator.div2 );
			Assert.isInstanceOf( code.locator.div1, js.html.DivElement );
			Assert.isInstanceOf( code.locator.div2, js.html.DivElement );
		}
	}
	#end
	
	//Import
	@Test( "test recursive empty import" )
	public function testRecursiveEmptyImport() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/emptyImport.flow", "BasicStaticFlowCompiler_testRecursiveEmptyImport" );
		code.execute();
		Assert.equals( 'hello world', code.locator.childContext.childContext.test );
	}
	
	@Test( "test two Int import" )
	public function testTwoIntImport() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/twoIntImport.flow", "BasicStaticFlowCompiler_testTwoIntImport" );
		code.execute( {x:10, y:20} );
		
		Assert.equals( 10, code.locator.size.width );
		Assert.equals( 20, code.locator.size.height );
		Assert.equals( 10, code.locator.xContext.x );
		Assert.equals( 20, code.locator.yContext.y );
	}
	
	@Test( "test Size import" )
	public function testSizeImport() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/sizeImport.flow", "BasicStaticFlowCompiler_testSizeImport" );
		code.execute( {x:10, y:20} );

		Assert.equals( 10, code.locator.sizeContext.size.width );
		Assert.equals( 20, code.locator.sizeContext.size.height );
		
		Assert.equals( 10, code.locator.width );
		Assert.equals( 20, code.locator.height );
	}
	
	@Test( "test recursive Size import" )
	public function testRecursiveSizeImport() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/recursiveSizeImport.flow", "BasicStaticFlowCompiler_testRecursiveSizeImport" );
		code.execute( {x:10, y:20} );

		Assert.equals( 10, code.locator.sizeContext1.sizeContext.size.width );
		Assert.equals( 20, code.locator.sizeContext1.sizeContext.size.height );
		Assert.equals( 10, code.locator.sizeContext2.sizeContext.size.width );
		Assert.equals( 20, code.locator.sizeContext2.sizeContext.size.height );
	}
	
	@Test( "test import with parent context dependency" )
	public function testImportWithParentContextDependency() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticFlowCompiler.compile( applicationAssembler, "context/flow/static/importWithParentDependency.flow", "BasicStaticFlowCompiler_testImportWithParentContextDependency" );
		code.execute();
		Assert.equals( 'hello world', code.locator.childContext.text );
	}
	
	@Test( "test import with child depending on another child" )
	public function testImportWithChildDependingOnAnotherChild() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticFlowCompiler.compile( applicationAssembler, "context/flow/static/importWithChildDependsOnChild.flow", "BasicStaticFlowCompiler_testImportWithChildDependingOnAnotherChild" );
		code.execute();
		Assert.equals( 'hello world', code.locator.childContext2.text );
	}
	
	@Test( "test child method call with another child argument" )
	public function testChildMethodCallWithAnotherChildArgument() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticFlowCompiler.compile( applicationAssembler, "context/flow/static/childMethodCallWithAnotherChildArg.flow", "BasicStaticFlowCompiler_testChildMethodCallWithAnotherChildArgument" );
		code.execute();
		Assert.deepEquals( [ 3, 4 ], code.locator.childContext3.o.owner.collection );
	}
	
	@Test( "test abstract typed field with map-type" )
	public function testAbstractTypedFieldWithMapType() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		var code = BasicStaticFlowCompiler.compile( applicationAssembler, "context/flow/static/abstractTypeField.flow", "BasicStaticFlowCompiler_testAbstractTypedFieldWithMapType" );
		code.execute();
		
		Assert.isInstanceOf( code.locator.test, MockClass );

		var map = code.applicationContext.getInjector().getInstanceWithClassName( "hex.mock.IMockInterface", "test" );
		Assert.isInstanceOf( map, MockClass );
		Assert.equals( code.locator.test, map );
		
		code.locator.test = new AnotherMockClass();
	}
	
	@Test( "test building lazy primitive" )
	public function testBuildingLazyString() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/primitives/lazyString.flow", "BasicStaticFlowCompiler_testBuildingLazyString" );
		LazyProvider.value = null;
		LazyClass.value = null;
		code.execute();
		
		Assert.isNull( LazyProvider.value  );
		Assert.equals( 'test', code.locator.s );
		Assert.equals( 'test', LazyProvider.value  );
		
		Assert.isNull( LazyClass.value  );
		Assert.isNotNull( code.locator.o );
		Assert.equals( 'test', LazyClass.value  );
	}
	
	@Test( "test composite runtine parameters" )
	public function testCompositeRuntimeParameters() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/static/compositeRuntimeParams.flow", "BasicStaticFlowCompiler_testCompositeRuntimeParameters" );
		var mock = new MockClass();
		code.execute( { p:{x: 30, y: 40}, test:{p:mock} } );
		
		Assert.isInstanceOf( code.locator.size, Size );
		Assert.equals( 30, code.locator.size.width );
		Assert.equals( 40, code.locator.size.height );
		
		Assert.equals( mock, code.locator.alias );
	}
	
	@Test( "test enum argument" )
	public function testEnumArgument() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/enumArgument.flow", "BasicStaticFlowCompiler_testEnumArgument" );
		code.execute();
		
		Assert.equals( hex.mock.MockColor.Red, code.locator.color );
		Assert.equals( hex.mock.MockColor.Red, code.locator.colored.color );
		Assert.equals( hex.mock.MockColor.Red, code.locator.colored2.color );
	}
	
	@Test( "test building public string" )
	public function testBuildingPublicString() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/primitives/publicString.flow", "BasicStaticFlowCompiler_testBuildingPublicString" );
		code.execute();
		
		Assert.equals( 'isPublic', code.locator.isPublic );
		Assert.equals( 'isPrivate', code.locator.wasPrivate );
		Assert.equals( '3', code.locator.isLazy );
		Assert.equals( '4', code.locator.wasPrivateAndLazy );
	}
	
	@Test( "test generic inference" )
	public function testGenericInference() : Void
	{
		Sample.value = null;
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/genericInference.flow", "BasicStaticFlowCompiler_testGenericInference" );
		code.execute();
		Assert.isNotNull( Sample.value );
	}
	
	@Test( "test closure returned from static call" )
	public function testClosureReturnedFromStaticCall() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/closureFromStaticCall.flow", "BasicStaticFlowCompiler_testClosureReturnedFromStaticCall" );
		code.execute();
		Assert.equals( "test", code.locator.test() );
	}
	
	@Test( "test bind on closure assignment" )
	public function testClosureAssignmentWithBind() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/closureWithBind.flow", "BasicStaticFlowCompiler_testClosureAssignmentWithBind" );
		code.execute();
		
		Assert.equals( 'test3', code.locator.binded('test') );
		Assert.equals( 'test3', code.locator.staticBinded('test') );
		
		Assert.equals( 'test3', code.locator.recursive.f1('test') );
		Assert.equals( 'test3', code.locator.recursive.f2('test') );
		
		Assert.equals( 'test3', code.locator.recursive.f3('test') );
		Assert.equals( 'test3', code.locator.recursive.f4('test') );
		
		Assert.equals( 'test3', (cast code.locator.mapping1.toValue)('test') );
		Assert.equals( 'test3', (cast code.locator.mapping2.toValue)('test') );
	}
}