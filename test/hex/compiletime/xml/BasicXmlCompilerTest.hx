package hex.compiletime.xml;

import hex.collection.HashMap;
import hex.core.IApplicationAssembler;
import hex.core.ICoreFactory;
import hex.di.Injector;
import hex.domain.Domain;
import hex.error.NoSuchElementException;
import hex.mock.AnotherMockClass;
import hex.mock.ClassWithConstantConstantArgument;
import hex.mock.IAnotherMockInterface;
import hex.mock.IMockInjectee;
import hex.mock.IMockInterface;
import hex.mock.MockCaller;
import hex.mock.MockChat;
import hex.mock.MockClass;
import hex.mock.MockClassWithGeneric;
import hex.mock.MockClassWithInjectedProperty;
import hex.mock.MockClassWithoutArgument;
import hex.mock.MockColorable;
import hex.mock.MockContextHolder;
import hex.mock.MockFruitVO;
import hex.mock.MockInjectee;
import hex.mock.MockMethodCaller;
import hex.mock.MockModuleWithInternalType.GetInfosInternalTypedef;
import hex.mock.MockObjectWithRegtangleProperty;
import hex.mock.MockProxy;
import hex.mock.MockReceiver;
import hex.mock.MockRectangle;
import hex.mock.MockServiceProvider;
import hex.runtime.ApplicationAssembler;
import hex.runtime.basic.ApplicationContext;
import hex.structures.Point;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

using tink.CoreApi;

/**
 * ...
 * @author Francis Bourre
 */
class BasicXmlCompilerTest 
{
	var _applicationAssembler 		: IApplicationAssembler;
	
	static var applicationAssembler : IApplicationAssembler;

	@Before
	public function setUp() : Void
	{

	}

	@After
	public function tearDown() : Void
	{
		this._applicationAssembler.release();
	}
	
	function _getCoreFactory() : ICoreFactory
	{
		return this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();
	}
	
	function _locate( key : String ) : Any
	{
		return this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory().locate( key );
	}
	
	@Test( "test context reference" )
	public function testContextReference() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/contextReference.xml" );
		var contextHolder : MockContextHolder = this._getCoreFactory().locate( "contextHolder" );
		var context = this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext );
		Assert.equals( context, contextHolder.context );
	}
	
	@Test( "test building String without context name" )
	public function testBuildingStringWithoutContextName() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/contextWithoutName.xml" );
		var s : String = this._getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Test( "test building String with assembler" )
	public function testBuildingStringWithAssembler() : Void
	{
		var assembler = new ApplicationAssembler();
		assembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory().register( "s2", "bonjour" );
		
		this._applicationAssembler = BasicXmlCompiler.compileWithAssembler( assembler, "context/xml/primitives/string.xml" );

		Assert.equals( "hello", this._getCoreFactory().locate( "s" ) );
		Assert.equals( "bonjour", this._getCoreFactory().locate( "s2" ) );
		Assert.equals( assembler, this._applicationAssembler );
	}
	
	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/primitives/string.xml" );
		var s : String = this._getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Test( "test building String with assembler property" )
	public function testBuildingStringWithAssemblerProperty() : Void
	{
		this._applicationAssembler = new ApplicationAssembler();
		BasicXmlCompiler.compileWithAssembler( this._applicationAssembler, "context/xml/primitives/string.xml" );
		var s : String = this._getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Test( "test building String with assembler static property" )
	public function testBuildingStringWithAssemblerStaticProperty() : Void
	{
		BasicXmlCompilerTest.applicationAssembler = new ApplicationAssembler();
		this._applicationAssembler = BasicXmlCompiler.compileWithAssembler( BasicXmlCompilerTest.applicationAssembler, "context/xml/primitives/string.xml" );
		var s : String = applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory().locate( "s" );
		Assert.equals( "hello", s );
	}
	
	@Test( "test read twice the same context" )
	public function testReadTwiceTheSameContext() : Void
	{
		var applicationAssembler = new ApplicationAssembler();
		this._applicationAssembler = new ApplicationAssembler();
		
		BasicXmlCompiler.compileWithAssembler( applicationAssembler, "context/xml/simpleInstanceWithoutArguments.xml" );
		BasicXmlCompiler.compileWithAssembler( this._applicationAssembler, "context/xml/simpleInstanceWithoutArguments.xml" );
		
		var localCoreFactory = applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getCoreFactory();

		var instance1 = localCoreFactory.locate( "instance" );
		Assert.isInstanceOf( instance1, MockClassWithoutArgument );
		
		var instance2 = this._getCoreFactory().locate( "instance" );
		Assert.isInstanceOf( instance2, MockClassWithoutArgument );
		
		Assert.notEquals( instance1, instance2 );
	}
	
	@Test( "test overriding context name" )
	public function testOverridingContextName() : Void
	{
		this._applicationAssembler = new ApplicationAssembler();
		
		BasicXmlCompiler.compileWithAssembler( this._applicationAssembler, "context/xml/simpleInstanceWithoutArguments.xml", 'name1', null, null );
		BasicXmlCompiler.compileWithAssembler( this._applicationAssembler, "context/xml/simpleInstanceWithoutArguments.xml", 'name2', null, null );
		
		var factory1 = this._applicationAssembler.getApplicationContext( "name1", ApplicationContext ).getCoreFactory();
		var factory2 = this._applicationAssembler.getApplicationContext( "name2", ApplicationContext ).getCoreFactory();

		var instance1 = factory1.locate( "instance" );
		Assert.isInstanceOf( instance1, MockClassWithoutArgument );
		
		var instance2 = factory2.locate( "instance" );
		Assert.isInstanceOf( instance2, MockClassWithoutArgument );
		
		Assert.notEquals( instance1, instance2 );
	}
	
	@Test( "test building Int" )
	public function testBuildingInt() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/primitives/int.xml" );
		var i : Int = this._getCoreFactory().locate( "i" );
		Assert.equals( -3, i );
	}
	
	@Test( "test building Hex" )
	public function testBuildingHex() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/primitives/hex.xml" );
		Assert.equals( 0xFFFFFF, this._getCoreFactory().locate( "i" ) );
	}
	
	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/primitives/bool.xml" );
		var b : Bool = this._getCoreFactory().locate( "b" );
		Assert.isTrue( b );
	}
	
	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/primitives/uint.xml" );
		var i : UInt = this._getCoreFactory().locate( "i" );
		Assert.equals( 3, i );
	}
	
	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/primitives/null.xml" );
		var result = this._getCoreFactory().locate( "value" );
		Assert.isNull( result );
	}
	
	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/anonymousObject.xml" );
		var obj : Dynamic = this._getCoreFactory().locate( "obj" );

		Assert.equals( "Francis", obj.name );
		Assert.equals( 44, obj.age );
		Assert.equals( 1.75, obj.height );
		Assert.isTrue( obj.isWorking );
		Assert.isFalse( obj.isSleeping );
		Assert.equals( 1.75, this._getCoreFactory().locate( "obj.height" ) );
	}

	@Test( "test building simple instance without arguments" )
	public function testBuildingSimpleInstanceWithoutArguments() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/simpleInstanceWithoutArguments.xml" );

		var instance : MockClassWithoutArgument = this._getCoreFactory().locate( "instance" );
		Assert.isInstanceOf( instance, MockClassWithoutArgument );
	}
	
	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/simpleInstanceWithArguments.xml" );

		var size : Size = this._getCoreFactory().locate( "size" );
		Assert.isInstanceOf( size, Size );
		Assert.equals( 10, size.width );
		Assert.equals( 20, size.height );
	}
	
	@Test( "test building multiple instances with arguments" )
	public function testBuildingMultipleInstancesWithArguments() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/multipleInstancesWithArguments.xml" );
		
		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.width );
		Assert.equals( 40, rect.height );

		var size : Size = this._getCoreFactory().locate( "size" );
		Assert.isInstanceOf( size, Size );
		Assert.equals( 15, size.width );
		Assert.equals( 25, size.height );

		var position : Point = this._getCoreFactory().locate( "position" );
		Assert.equals( 35, position.x );
		Assert.equals( 45, position.y );
	}
	
	@Test( "test building single instance with primitives references" )
	public function testBuildingSingleInstanceWithPrimitivesReferences() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/singleInstanceWithPrimReferences.xml" );
		
		var x : Int = this._getCoreFactory().locate( "x" );
		Assert.equals( 1, x );
		
		var y : Int = this._getCoreFactory().locate( "y" );
		Assert.equals( 2, y );

		var position : Point = this._getCoreFactory().locate( "position" );
		Assert.equals( 1, position.x );
		Assert.equals( 2, position.y );
	}

	@Test( "test building single instance with method references" )
	public function testBuildingSingleInstanceWithMethodReferences() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/singleInstanceWithMethodReferences.xml" );
		
		var chat : MockChat = this._getCoreFactory().locate( "chat" );
		Assert.isInstanceOf( chat, MockChat );
		
		var receiver : MockReceiver = this._getCoreFactory().locate( "receiver" );
		Assert.isInstanceOf( receiver, MockReceiver );
		
		var proxyChat : MockProxy = this._getCoreFactory().locate( "proxyChat" );
		Assert.isInstanceOf( proxyChat, MockProxy );
		
		var proxyReceiver : MockProxy = this._getCoreFactory().locate( "proxyReceiver" );
		Assert.isInstanceOf( proxyReceiver, MockProxy );

		Assert.equals( chat, proxyChat.scope );
		Assert.equals( chat.onTranslation, proxyChat.callback );
		
		Assert.equals( receiver, proxyReceiver.scope );
		Assert.equals( receiver.onMessage, proxyReceiver.callback );
	}
	
	@Test( "test building multiple instances with references" )
	public function testAssignInstancePropertyWithReference() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/instancePropertyWithReference.xml" );
		
		var width : Int = this._getCoreFactory().locate( "width" );
		Assert.equals( 10, width );
		
		var height : Int = this._getCoreFactory().locate( "height" );
		Assert.equals( 20, height );
		
		var size : Point = this._getCoreFactory().locate( "size" );
		Assert.equals( width, size.x );
		Assert.equals( height, size.y );
		
		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.equals( width, rect.size.x );
		Assert.equals( height, rect.size.y );
	}
	
	@Test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/multipleInstancesWithReferences.xml" );

		var rectSize : Point = this._getCoreFactory().locate( "rectSize" );
		Assert.equals( 30, rectSize.x );
		Assert.equals( 40, rectSize.y );

		var rectPosition : Point = this._getCoreFactory().locate( "rectPosition" );
		Assert.equals( 10, rectPosition.x );
		Assert.equals( 20, rectPosition.y );

		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.size.x );
		Assert.equals( 40, rect.size.y );
	}
	
	@Test( "test simple method call" )
	public function testSimpleMethodCall() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/simpleMethodCall.xml" );

		var caller : MockCaller = this._getCoreFactory().locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments );
	}
	
	@Test( "test method call with type params" )
	public function testCallWithTypeParams() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/methodCallWithTypeParams.xml" );

		var caller : MockCaller = this._getCoreFactory().locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller, "" );
		Assert.equals( 3, MockCaller.passedArray.length, "" );
	}
	
	@Test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/multipleInstancesWithMethodCall.xml" );

		var rectSize : Point = this._getCoreFactory().locate( "rectSize" );
		Assert.equals( 30, rectSize.x );
		Assert.equals( 40, rectSize.y );

		var rectPosition : Point = this._getCoreFactory().locate( "rectPosition" );
		Assert.equals( 10, rectPosition.x );
		Assert.equals( 20, rectPosition.y );


		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.width );
		Assert.equals( 40, rect.height );

		var anotherRect : MockRectangle = this._getCoreFactory().locate( "anotherRect" );
		Assert.isInstanceOf( anotherRect, MockRectangle );
		Assert.equals( 0, anotherRect.x );
		Assert.equals( 0, anotherRect.y );
		Assert.equals( 0, anotherRect.width );
		Assert.equals( 0, anotherRect.height );
	}
	
	
	@Test( "test building instance with static method" )
	public function testBuildingInstanceWithStaticMethod() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/instanceWithStaticMethod.xml" );

		var service : MockServiceProvider = this._getCoreFactory().locate( "service" );
		Assert.isInstanceOf( service, MockServiceProvider );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway(), "" );
	}
	
	@Test( "test building instance with static method and arguments" )
	public function testBuildingInstanceWithStaticMethodAndArguments() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/instanceWithStaticMethodAndArguments.xml" );

		var rect : MockRectangle = this._getCoreFactory().locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.width );
		Assert.equals( 40, rect.height );
	}
	
	@Test( "test building instance with static method and factory method" )
	public function testBuildingInstanceWithStaticMethodAndFactoryMethod() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/instanceWithStaticMethodAndFactoryMethod.xml" );
		var point : Point = this._getCoreFactory().locate( "point" );

		Assert.equals( 10, point.x );
		Assert.equals( 20, point.y );
	}
	
	@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/injectIntoAttribute.xml" );

		var instance : MockClassWithInjectedProperty = this._getCoreFactory().locate( "instance" );
		Assert.isInstanceOf( instance, MockClassWithInjectedProperty, "" );
		Assert.equals( "hola mundo", instance.property, "" );
		Assert.isTrue( instance.postConstructWasCalled, "" );
	}
	
	@Test( "test building XML without parser class" )
	public function testBuildingXMLWithoutParserClass() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/xmlWithoutParserClass.xml" );

		var fruits : Xml = this._getCoreFactory().locate( "fruits" );
		Assert.isNotNull( fruits );
		Assert.isInstanceOf( fruits, Xml );
	}
	
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/xmlWithParserClass.xml" );

		var fruits : Array<MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.equals( 3, fruits.length, "" );

		var orange : MockFruitVO = fruits[0];
		var apple : MockFruitVO = fruits[1];
		var banana : MockFruitVO = fruits[2];

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		Assert.equals( "banana", banana.toString(), "" );
	}
	
	@Test( "test building Arrays" )
	public function testBuildingArrays() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/arrayFilledWithReferences.xml" );
		
		var text : Array<String> = this._getCoreFactory().locate( "text" );
		Assert.equals( 2, text.length );
		Assert.equals( "hello", text[ 0 ] );
		Assert.equals( "world", text[ 1 ] );
		
		var empty : Array<String> = this._getCoreFactory().locate( "empty" );
		Assert.equals( 0, empty.length );

		var fruits : Array<MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.equals( 3, fruits.length, "" );

		var orange 	: MockFruitVO = fruits[0];
		var apple 	: MockFruitVO = fruits[1];
		var banana 	: MockFruitVO = fruits[2];

		Assert.equals( "orange", orange.toString()  );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}
	
	@Test( "test building Map filled with references" )
	public function testBuildingMapFilledWithReferences() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/hashmapFilledWithReferences.xml" );

		var fruits : HashMap<Dynamic, MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.isNotNull( fruits );

		var stubKey : Point = this._getCoreFactory().locate( "stubKey" );
		Assert.isNotNull( stubKey );

		Assert.equals( "orange", fruits.get( '0' ).toString() );
		Assert.equals( "apple", fruits.get( 1 ).toString() );
		Assert.equals( "banana", fruits.get( stubKey ).toString() );
	}

	@Test( "test building HashMap with map-type" )
	public function testBuildingHashMapWithMapType() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/hashmapWithMapType.xml" );

		var fruits : HashMap<Any, MockFruitVO> = this._getCoreFactory().locate( "fruits" );
		Assert.isNotNull( fruits, "" );

		var orange 	: MockFruitVO = fruits.get( '0' );
		var apple 	: MockFruitVO = fruits.get( '1' );

		Assert.equals( "orange", orange.toString(), "" );
		Assert.equals( "apple", apple.toString(), "" );
		
		var map = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.collection.HashMap<String,hex.mock.MockFruitVO>", "fruits" );
		Assert.equals( fruits, map );
	}
	
	@Test( "test map-type attribute with Array" )
	public function testMapTypeWithArray() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/mapTypeWithArray.xml" );
		
		var intCollection = this._getCoreFactory().getInjector().getInstanceWithClassName( "Array<Int>", "intCollection" );
		var uintCollection = this._getCoreFactory().getInjector().getInstanceWithClassName( "Array<UInt>", "intCollection" );
		var stringCollection = this._getCoreFactory().getInjector().getInstanceWithClassName( "Array<String>", "stringCollection" );
		
		Assert.isInstanceOf( intCollection, Array );
		Assert.isInstanceOf( uintCollection, Array );
		Assert.isInstanceOf( stringCollection, Array );
		
		Assert.equals( intCollection, uintCollection );
		Assert.notEquals( intCollection, stringCollection );
	}
	
	@Test( "test map-type attribute with instance" )
	public function testMapTypeWithInstance() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/mapTypeWithInstance.xml" );
		
		var intInstance = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<Int>", "intInstance" );
		var uintInstance = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<UInt>", "intInstance" );
		var stringInstance = this._getCoreFactory().getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<String>", "stringInstance" );

		Assert.isInstanceOf( intInstance, MockClassWithGeneric );
		Assert.isInstanceOf( uintInstance, MockClassWithGeneric );
		Assert.isInstanceOf( stringInstance, MockClassWithGeneric );
		
		Assert.equals( intInstance, uintInstance );
		Assert.notEquals( intInstance, stringInstance );
	}
	
	@Test( "test building class reference" )
	public function testBuildingClassReference() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/classReference.xml" );

		var rectangleClass : Class<MockRectangle> = this._getCoreFactory().locate( "RectangleClass" );
		Assert.isInstanceOf( rectangleClass, Class, "" );
		Assert.isInstanceOf( Type.createInstance( rectangleClass, [] ), MockRectangle, "" );

		var classContainer = this._getCoreFactory().locate( "classContainer" );

		var anotherRectangleClass : Class<MockRectangle> = classContainer.AnotherRectangleClass;
		Assert.isInstanceOf( anotherRectangleClass, Class, "" );
		Assert.isInstanceOf( Type.createInstance( anotherRectangleClass, [] ), MockRectangle, "" );

		Assert.equals( rectangleClass, anotherRectangleClass, "" );

		var anotherRectangleClassRef : Class<MockRectangle> = this._getCoreFactory().locate( "classContainer.AnotherRectangleClass" );
		Assert.isInstanceOf( anotherRectangleClassRef, Class, "" );
		Assert.equals( anotherRectangleClass, anotherRectangleClassRef, "" );
	}
	
	@Test( "test static-ref" )
	public function testStaticRef() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/staticRef.xml" );

		var messageType : String = this._getCoreFactory().locate( "constant" );
		Assert.isNotNull( messageType );
		Assert.equals( messageType, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref property" )
	public function testStaticProperty() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/staticRefProperty.xml" );

		var object : Dynamic = this._getCoreFactory().locate( "object" );
		Assert.isNotNull( object );
		Assert.equals( MockClass.MESSAGE_TYPE, object.property );
		
		var object2 : Dynamic = this._getCoreFactory().locate( "object2" );
		Assert.isNotNull( object2 );
		Assert.equals( MockClass, object2.property );
	}
	
	@Test( "test static-ref argument" )
	public function testStaticArgument() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/staticRefArgument.xml" );

		var instance : ClassWithConstantConstantArgument = this._getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( instance.constant, MockClass.MESSAGE_TYPE );
	}
	
	@Test( "test static-ref argument on method-call" )
	public function testStaticArgumentOnMethodCall() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/staticRefArgumentOnMethodCall.xml" );

		var instance : MockMethodCaller = this._getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( MockMethodCaller.staticVar, instance.argument );
	}
	
	@Test( "test map-type attribute" )
	public function testMapTypeAttribute() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/mapTypeAttribute.xml" );

		var instance : MockClass = this._getCoreFactory().locate( "instance" );
		Assert.isNotNull( instance );
		Assert.isInstanceOf( instance, MockClass );
		Assert.isInstanceOf( instance, IMockInterface );
		Assert.equals( instance, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IMockInterface, "instance" ) );
	
		var instance2 : MockClass = this._getCoreFactory().locate( "instance2" );
		Assert.isNotNull( instance2 );
		Assert.isInstanceOf( instance2, MockClass );
		Assert.equals( instance2, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstanceWithClassName( 'hex.mock.MockModuleWithInternalType.GetInfosInternalTypedef', "instance2" ) );
	}
	
	@Test( "test multi map-type attributes" )
	public function testMultiMapTypeAttributes() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/static/multiMapTypeAttributes.xml" );

		var instance = this._getCoreFactory().locate( "instance" );
		var f = this._getCoreFactory().locate( "f" );
		var f2 = this._getCoreFactory().locate( "f2" );
		
		Assert.isInstanceOf( instance, MockClass );
		Assert.isInstanceOf( instance, IMockInterface );
		Assert.isInstanceOf( instance, IAnotherMockInterface );

		Assert.equals( instance, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IMockInterface, "instance" ) );
		Assert.equals( instance, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IAnotherMockInterface, "instance" ) );
		
		Assert.equals( f, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstanceWithClassName( "String->String", "f" ) );
		Assert.equals( f, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstanceWithClassName( "hex.mock.MockModuleWithInternalType.FunctionSignature", "f" ) );
	
		Assert.equals( f2, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstanceWithClassName( "String->String", "f2" ) );
		Assert.equals( f2, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstanceWithClassName( "hex.mock.MockModuleWithInternalType.FunctionSignature", "f2" ) );
		
		Assert.equals( f, this._getCoreFactory().locate( "instanceWithSubType.toInject1" ) );
		Assert.equals( f2, this._getCoreFactory().locate( "instanceWithSubType.toInject2" ) );
		Assert.equals( f, this._getCoreFactory().locate( "instanceWithSubType.toInject1b" ) );
		Assert.equals( f2, this._getCoreFactory().locate( "instanceWithSubType.toInject2b" ) );
		Assert.equals( f, this._getCoreFactory().locate( "instanceWithSubType.toInject1c" ) );
		Assert.equals( f2, this._getCoreFactory().locate( "instanceWithSubType.toInject2c" ) );
	}
	
	@Test( "test building Map with class reference" )
	public function testBuildingMapWithClassReference() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/hashmapWithClassReference.xml" );

		var map : HashMap<Class<IMockInterface>, Class<MockClass>> = this._locate( "map" );
		Assert.isNotNull( map );
		
		var amazonServiceClass : Class<MockClass> = map.get( IMockInterface );
		Assert.equals( IMockInterface, map.getKeys()[ 0 ] );
		Assert.equals( MockClass, amazonServiceClass );
	}
	
	@Test( "test target sub property" )
	public function testTargetSubProperty() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/targetSubProperty.xml" );

		var mockObject : MockObjectWithRegtangleProperty = this._locate( "mockObject" );
		Assert.isInstanceOf( mockObject, MockObjectWithRegtangleProperty );
		Assert.equals( 1.5, mockObject.rectangle.x );
	}

	@Test( "test recursive property reference" )
	public function testRecursivePropertyReference() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/propertyReference.xml" );

		var oClass : hex.mock.MockClassWithProperty = this._locate( "oClass" );
		var oDynamic : Dynamic = this._locate( "oDynamic" );

		Assert.equals( 'property', oClass.property );
		Assert.equals( 'property', oDynamic.p );
	}

	@Test( "test recursive property reference to reference" )
	public function testRecursivePropertyReferenceToReference() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/propertyReferenceToReference.xml" );

		var oClass : hex.mock.MockClassWithProperty = this._locate( "oClass" );
		var oDynamic : Dynamic = this._locate( "oDynamic" );

		Assert.equals( 'property', oClass.property );
		Assert.equals( 'property', oDynamic.p );
	}
	
	/*@Test( "test parsing twice" )
	public function testParsingTwice() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/parsingOnce.xml" );
		BasicXmlCompiler.compileWithAssembler( this._applicationAssembler, "context/xml/parsingTwice.xml" );

		var rect0 : MockRectangle = this._locate( "rect0" );
		Assert.isInstanceOf( rect0, MockRectangle );
		Assert.equals( 10, rect0.x );
		Assert.equals( 20, rect0.y );
		Assert.equals( 30, rect0.width );
		Assert.equals( 40, rect0.height );

		var rect1 : MockRectangle = this._locate( "rect1" );
		Assert.isInstanceOf( rect1, MockRectangle );
		Assert.equals( 50, rect1.x );
		Assert.equals( 60, rect1.y );
		Assert.equals( 70, rect1.width );
		Assert.equals( 40, rect1.height );
	}*/
	
	@Test( "test simple method call from another node" )
	public function testSimpleMethodCallFromAnotherNode() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/simpleMethodCallFromAnotherNode.xml" );

		var caller : MockCaller = this._locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller, "" );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments, "" );
	}

	@Test( "test if attribute" )
	public function testIfAttribute() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/ifAttribute.xml", null, null, [ "production" => true, "test" => false, "release" => false ] );
		Assert.equals( "hello production", this._locate( "message" ), "message value should equal 'hello production'" );
	}

	@Test( "test include with if attribute" )
	public function testIncludeWithIfAttribute() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/includeWithIfAttribute.xml", null, null, [ "production" => true, "test" => false, "release" => false ] );
		Assert.equals( "hello production", this._locate( "message" ), "message value should equal 'hello production'" );
	}

	@Test( "test include fails with if attribute" )
	public function testIncludeFailsWithIfAttribute() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/includeWithIfAttribute.xml", null, null, [ "production" => false, "test" => true, "release" => true ] );
		Assert.methodCallThrows( NoSuchElementException, this._getCoreFactory(), this._locate, [ "message" ], "'NoSuchElementException' should be thrown" );
	}

	@Test( "test file preprocessor with Xml file" )
	public function testFilePreprocessorWithXmlFile() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/preprocessor.xml", [	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] );

		Assert.equals( "bonjour", this._locate( "message" ), "message value should equal 'bonjour'" );
	}

	@Test( "test file preprocessor with Xml file and include" )
	public function testFilePreprocessorWithXmlFileAndInclude() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/preprocessorWithInclude.xml", null, [	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] );

		try
        {
			Assert.equals( "bonjour", this._locate( "message" ), "message value should equal 'bonjour'" );
		}
		catch ( e : Error )
        {
            Assert.fail( e.message, "Exception on this._locate( \"message\" ) call" );
        }
	}
	
	/*@Test( "test trigger method connection" )
	public function testTriggerMethodConnection() : Void
	{
		MockTriggerListener.callbackCount = 0;
		MockTriggerListener.message = '';
		
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/trigger.xml" );

		var model : MockModelWithTrigger = this._locate( "model" );
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
		
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/trigger.xml" );

		var model : MockModelWithTrigger = this._locate( "model" );
		Assert.isInstanceOf( model, MockModelWithTrigger );
		
		model.trigger.onTrigger( 'hello world' );
		Assert.equals( 1, MockTriggerListener.callbackCount );
		Assert.equals( 'hello world', MockTriggerListener.message );
	}*/
	
	@Test( "test enum argument" )
	public function testEnumArgument() : Void
	{
		this._applicationAssembler = BasicXmlCompiler.compile( "context/xml/enumArgument.xml" );
		var colored : MockColorable = cast this._locate( "colored" );
		Assert.equals( hex.mock.MockColor.Red, colored.color );
	}
}