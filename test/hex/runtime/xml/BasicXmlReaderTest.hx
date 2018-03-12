package hex.runtime.xml;

import hex.collection.HashMap;
import hex.core.IApplicationAssembler;
import hex.core.IApplicationContext;
import hex.di.Injector;
import hex.di.mapping.MappingConfiguration;
import hex.domain.Domain;
import hex.error.Exception;
import hex.error.NoSuchElementException;
import hex.event.Dispatcher;
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
import hex.mock.MockFruitVO;
import hex.mock.MockInjectee;
import hex.mock.MockMethodCaller;
import hex.mock.MockObjectWithRegtangleProperty;
import hex.mock.MockProxy;
import hex.mock.MockReceiver;
import hex.mock.MockRectangle;
import hex.mock.MockServiceProvider;
import hex.runtime.basic.ApplicationContext;
import hex.runtime.basic.CoreFactory;
import hex.structures.Point;
import hex.structures.PointFactory;
import hex.structures.Size;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BasicXmlReaderTest
{
	var _contextParser 				: ApplicationParser;
	var _applicationContext 		: IApplicationContext;
	var _applicationAssembler 		: IApplicationAssembler;
		
	@Before
	public function setUp() : Void
	{
		this._applicationAssembler 	= new ApplicationAssembler();
		this._applicationContext 	= this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext );
		cast ( this._applicationContext.getCoreFactory(), CoreFactory ).addProxyFactoryMethod( "hex.structures.Point", PointFactory, PointFactory.build );
	}

	@After
	public function tearDown() : Void
	{
		this._applicationAssembler.release();
	}
	
	function _locate( key : String ) : Dynamic
	{
		return this._applicationContext.getCoreFactory().locate( key );
	}
	
	function build( xml : Xml ) : Void
	{
		this._contextParser = new ApplicationParser();
		this._contextParser.parse( this._applicationAssembler, xml );
	}

	@Test( "test building String" )
	public function testBuildingString() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/primitives/string.xml" ) );
		Assert.equals( "hello", this._locate( "s" ) );
	}
	
	@Test( "test building Int" )
	public function testBuildingInt() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/primitives/int.xml" ) );
		Assert.equals( -3, this._locate( "i" ) );
	}
	
	@Test( "test building Hex" )
	public function testBuildingHex() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/primitives/hex.xml" ) );
		Assert.equals( 0xFFFFFF, this._locate( "i" ) );
	}

	@Test( "test building Bool" )
	public function testBuildingBool() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/primitives/bool.xml" ) );
		Assert.isTrue( this._locate( "b" ) );
	}

	@Test( "test building UInt" )
	public function testBuildingUInt() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/primitives/uint.xml" ) );
		Assert.equals( 3, this._locate( "i" ) );
	}

	@Test( "test building null" )
	public function testBuildingNull() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/primitives/null.xml" ) );
		Assert.isNull( this._locate( "value" ) );
	}

	@Test( "test building anonymous object" )
	public function testBuildingAnonymousObject() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/anonymousObject.xml" ) );
		var obj : Dynamic = this._locate( "obj" );

		Assert.equals( "Francis", obj.name );
		Assert.equals( 44, obj.age );
		Assert.equals( 1.75, obj.height );
		Assert.isTrue( obj.isWorking );
		Assert.isFalse( obj.isSleeping );
		Assert.equals( 1.75, this._locate( "obj.height" ) );
	}

	@Test( "test building simple instance with arguments" )
	public function testBuildingSimpleInstanceWithArguments() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/simpleInstanceWithArguments.xml" ) );

		var size : Size = this._locate( "size" );
		Assert.isInstanceOf( size, Size );
		Assert.equals( 10, size.width );
		Assert.equals( 20, size.height );
	}

	@Test( "test building multiple instances with arguments" )
	public function testBuildingMultipleInstancesWithArguments() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/multipleInstancesWithArguments.xml" ) );

		var size : Size = this._locate( "size" );
		Assert.isInstanceOf( size, Size );
		Assert.equals( 15, size.width );
		Assert.equals( 25, size.height );

		var position : Point = this._locate( "position" );
		//Assert.isInstanceOf( position, Point );
		Assert.equals( 35, position.x );
		Assert.equals( 45, position.y );
	}

	@Test( "test building single instance with primitives references" )
	public function testBuildingSingleInstanceWithPrimitivesReferences() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/singleInstanceWithPrimReferences.xml" ) );
		
		var x : Int = this._locate( "x" );
		Assert.equals( 1, x );
		
		var y : Int = this._locate( "y" );
		Assert.equals( 2, y );

		var position : Point = this._locate( "position" );
		//Assert.isInstanceOf( position, Point );
		Assert.equals( 1, position.x );
		Assert.equals( 2, position.y );
	}

	@Test( "test building single instance with method references" )
	public function testBuildingSingleInstanceWithMethodReferences() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/singleInstanceWithMethodReferences.xml" ) );
		
		var chat : MockChat = this._locate( "chat" );
		Assert.isInstanceOf( chat, MockChat );
		
		var receiver : MockReceiver = this._locate( "receiver" );
		Assert.isInstanceOf( receiver, MockReceiver );
		
		var proxyChat : MockProxy = this._locate( "proxyChat" );
		Assert.isInstanceOf( proxyChat, MockProxy );
		
		var proxyReceiver : MockProxy = this._locate( "proxyReceiver" );
		Assert.isInstanceOf( proxyReceiver, MockProxy );

		Assert.equals( chat, proxyChat.scope );
		Assert.equals( chat.onTranslation(), proxyChat.call() );
		
		Assert.equals( receiver, proxyReceiver.scope );
		Assert.equals( receiver.onMessage(), proxyReceiver.call() );
	}

	@Test( "test building multiple instances with references" )
	public function testAssignInstancePropertyWithReference() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/instancePropertyWithReference.xml" ) );
		
		var width : Int = this._locate( "width" );
		Assert.equals( 10, width );
		
		var height : Int = this._locate( "height" );
		Assert.equals( 20, height );
		
		var size : Point = this._locate( "size" );
		//Assert.isInstanceOf( size, Point );
		Assert.equals( width, size.x );
		Assert.equals( height, size.y );
		
		var rect : MockRectangle = this._locate( "rect" );
		Assert.equals( width, rect.size.x );
		Assert.equals( height, rect.size.y );
	}

	@Test( "test building multiple instances with references" )
	public function testBuildingMultipleInstancesWithReferences() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/multipleInstancesWithReferences.xml" ) );

		var rectSize : Point = this._locate( "rectSize" );
		//Assert.isInstanceOf( rectSize, Point );
		Assert.equals( 30, rectSize.x );
		Assert.equals( 40, rectSize.y );

		var rectPosition : Point = this._locate( "rectPosition" );
		//Assert.isInstanceOf( rectPosition, Point );
		Assert.equals( 10, rectPosition.x );
		Assert.equals( 20, rectPosition.y );


		var rect : MockRectangle = this._locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.size.x );
		Assert.equals( 40, rect.size.y );
	}

	@Test( "test simple method call" )
	public function testSimpleMethodCall() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/simpleMethodCall.xml" ) );

		var caller : MockCaller = this._locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller, "" );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments, "" );
	}

	@Test( "test method call with type params" )
	public function testCallWithTypeParams() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/methodCallWithTypeParams.xml" ) );

		var caller : MockCaller = this._locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller, "" );
		Assert.equals( 3, MockCaller.passedArray.length, "" );
	}

	@Test( "test building multiple instances with method calls" )
	public function testBuildingMultipleInstancesWithMethodCall() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/multipleInstancesWithMethodCall.xml" ) );

		var rectSize : Point = this._locate( "rectSize" );
		//Assert.isInstanceOf( rectSize, Point );
		Assert.equals( 30, rectSize.x );
		Assert.equals( 40, rectSize.y );

		var rectPosition : Point = this._locate( "rectPosition" );
		//Assert.isInstanceOf( rectPosition, Point );
		Assert.equals( 10, rectPosition.x );
		Assert.equals( 20, rectPosition.y );


		var rect : MockRectangle = this._locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.width );
		Assert.equals( 40, rect.height );

		var anotherRect : MockRectangle = this._locate( "anotherRect" );
		Assert.isInstanceOf( anotherRect, MockRectangle );
		Assert.equals( 0, anotherRect.x );
		Assert.equals( 0, anotherRect.y );
		Assert.equals( 0, anotherRect.width );
		Assert.equals( 0, anotherRect.height );
	}

	@Test( "test building instance with static method" )
	public function testBuildingInstanceWithStaticMethod() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/instanceWithStaticMethod.xml" ) );

		var service : MockServiceProvider = this._locate( "service" );
		Assert.isInstanceOf( service, MockServiceProvider );
		Assert.equals( "http://localhost/amfphp/gateway.php", MockServiceProvider.getInstance().getGateway() );
	}

	@Test( "test building instance with static method and arguments" )
	public function testBuildingInstanceWithStaticMethodAndArguments() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/instanceWithStaticMethodAndArguments.xml" ) );

		var rect : MockRectangle = this._locate( "rect" );
		Assert.isInstanceOf( rect, MockRectangle );
		Assert.equals( 10, rect.x );
		Assert.equals( 20, rect.y );
		Assert.equals( 30, rect.width );
		Assert.equals( 40, rect.height );
	}

	@Test( "test building instance with static method and factory method" )
	public function testBuildingInstanceWithStaticMethodAndFactoryMethod() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/instanceWithStaticMethodAndFactoryMethod.xml" ) );

		var point : Point = this._locate( "point" );
		//Assert.isInstanceOf( point, Point );
		Assert.equals( 10, point.x );
		Assert.equals( 20, point.y );
	}

	@Test( "test 'inject-into' attribute" )
	public function testInjectIntoAttribute() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/injectIntoAttribute.xml" ) );

		var instance : MockClassWithInjectedProperty = this._locate( "instance" );
		Assert.isInstanceOf( instance, MockClassWithInjectedProperty );
		Assert.equals( "hola mundo", instance.property );
		Assert.isTrue( instance.postConstructWasCalled );
	}

	@Test( "test building XML without parser class" )
	public function testBuildingXMLWithoutParserClass() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/xmlWithoutParserClass.xml" ) );

		var fruits : Xml = this._locate( "fruits" );
		Assert.isNotNull( fruits );
		Assert.isInstanceOf( fruits, Xml );
	}

	#if !flash
	//todo have to fixe this test issue on Flash target
	@Test( "test building XML with parser class" )
	public function testBuildingXMLWithParserClass() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/xmlWithParserClass.xml" ) );

		var fruits : Array<MockFruitVO> = this._locate( "fruits" );
		Assert.equals( 3, fruits.length );

		var orange : MockFruitVO = fruits[0];
		var apple : MockFruitVO = fruits[1];
		var banana : MockFruitVO = fruits[2];

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}
	#end

	@Test( "test building Arrays" )
	public function testBuildingArrays() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/arrayFilledWithReferences.xml" ) );
		
		var text : Array<String> = this._locate( "text" );
		Assert.equals( 2, text.length );
		Assert.equals( "hello", text[ 0 ] );
		Assert.equals( "world", text[ 1 ] );
		
		var empty : Array<String> = this._locate( "empty" );
		Assert.equals( 0, empty.length );

		var fruits : Array<MockFruitVO> = this._locate( "fruits" );
		Assert.equals( 3, fruits.length );

		var orange 	: MockFruitVO = fruits[0];
		var apple 	: MockFruitVO = fruits[1];
		var banana 	: MockFruitVO = fruits[2];

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}

	@Test( "test building Map filled with references" )
	public function testBuildingMapFilledWithReferences() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/hashmapFilledWithReferences.xml" ) );

		var fruits : HashMap<Any, MockFruitVO> = this._locate( "fruits" );
		Assert.isNotNull( fruits );

		var stubKey : Point = this._locate( "stubKey" );
		Assert.isNotNull( stubKey );

		var orange 	: MockFruitVO = fruits.get( '0' );
		var apple 	: MockFruitVO = fruits.get( 1 );
		var banana 	: MockFruitVO = fruits.get( stubKey );

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		Assert.equals( "banana", banana.toString() );
	}

	@Test( "test building HashMap with map-type" )
	public function testBuildingHashMapWithMapType() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/hashmapWithMapType.xml" ) );

		var fruits : HashMap<Any, MockFruitVO> = this._locate( "fruits" );
		Assert.isNotNull( fruits );

		var orange 	: MockFruitVO = fruits.get( '0' );
		var apple 	: MockFruitVO = fruits.get( '1' );

		Assert.equals( "orange", orange.toString() );
		Assert.equals( "apple", apple.toString() );
		
		var map = this._applicationContext.getInjector().getInstanceWithClassName( "hex.collection.HashMap<String,hex.mock.MockFruitVO>", "fruits" );
		Assert.equals( fruits, map );
	}

	@Test( "test map-type attribute with Array" )
	public function testMapTypeWithArray() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/mapTypeWithArray.xml" ) );
		
		var intCollection = this._applicationContext.getInjector().getInstanceWithClassName( "Array<Int>", "intCollection" );
		var intCollection = this._applicationContext.getInjector().getInstanceWithClassName( "Array<UInt>", "intCollection" );
		var stringCollection = this._applicationContext.getInjector().getInstanceWithClassName( "Array<String>", "stringCollection" );
		
		Assert.isInstanceOf( intCollection, Array );
		Assert.isInstanceOf( stringCollection, Array );
		Assert.notEquals( intCollection, stringCollection );
	}
	
	@Test( "test map-type attribute with instance" )
	public function testMapTypeWithInstance() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/mapTypeWithInstance.xml" ) );
		
		var intInstance = this._applicationContext.getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<Int>", "intInstance" );
		var uintInstance = this._applicationContext.getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<UInt>", "intInstance" );
		var stringInstance = this._applicationContext.getInjector().getInstanceWithClassName( "hex.mock.IMockInterfaceWithGeneric<String>", "stringInstance" );

		Assert.isInstanceOf( intInstance, MockClassWithGeneric );
		Assert.isInstanceOf( uintInstance, MockClassWithGeneric );
		Assert.isInstanceOf( stringInstance, MockClassWithGeneric );
		
		Assert.equals( intInstance, uintInstance );
		Assert.notEquals( intInstance, stringInstance );
	}

	@Test( "test building class reference" )
	public function testBuildingClassReference() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/classReference.xml" ) );

		var rectangleClass : Class<MockRectangle> = this._locate( "RectangleClass" );
		Assert.isInstanceOf( rectangleClass, Class );
		Assert.isInstanceOf( Type.createInstance( rectangleClass, [] ), MockRectangle );

		var classContainer = this._locate( "classContainer" );

		var anotherRectangleClass : Class<MockRectangle> = classContainer.AnotherRectangleClass;
		Assert.isInstanceOf( anotherRectangleClass, Class );
		Assert.isInstanceOf( Type.createInstance( anotherRectangleClass, [] ), MockRectangle );

		Assert.equals( rectangleClass, anotherRectangleClass );

		var anotherRectangleClassRef : Class<MockRectangle> = this._locate( "classContainer.AnotherRectangleClass" );
		Assert.isInstanceOf( anotherRectangleClassRef, Class );
		Assert.equals( anotherRectangleClass, anotherRectangleClassRef );
	}

	@Test( "test static-ref" )
	public function testStaticRef() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/staticRef.xml" ) );

		var messageType : String = this._locate( "constant" );
		Assert.isNotNull( messageType );
		Assert.equals( messageType, MockClass.MESSAGE_TYPE );
	}

	@Test( "test static-ref property" )
	public function testStaticProperty() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/staticRefProperty.xml" ) );

		var object : Dynamic = this._locate( "object" );
		Assert.isNotNull( object );
		Assert.equals( MockClass.MESSAGE_TYPE, object.property );
		
		var object2 : Dynamic = this._locate( "object2" );
		Assert.isNotNull( object2 );
		Assert.equals( MockClass, object2.property );
	}

	@Test( "test static-ref argument" )
	public function testStaticArgument() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/staticRefArgument.xml" ) );

		var instance : ClassWithConstantConstantArgument = this._locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( instance.constant, MockClass.MESSAGE_TYPE );
	}

	@Test( "test static-ref argument on method-call" )
	public function testStaticArgumentOnMethodCall() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/staticRefArgumentOnMethodCall.xml" ) );

		var instance : MockMethodCaller = this._locate( "instance" );
		Assert.isNotNull( instance, "" );
		Assert.equals( MockMethodCaller.staticVar, instance.argument, "" );
	}

	@Test( "test map-type attribute" )
	public function testMapTypeAttribute() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/mapTypeAttribute.xml" ) );

		var instance : MockClass = this._locate( "instance" );
		Assert.isNotNull( instance );
		Assert.isInstanceOf( instance, MockClass );
		Assert.isInstanceOf( instance, IMockInterface );
		Assert.equals( instance, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IMockInterface, "instance" ) );
	}

	@Test( "test multi map-type attributes" )
	public function testMultiMapTypeAttributes() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/multiMapTypeAttributes.xml" ) );

		var instance : MockClass = this._locate( "instance" );
		Assert.isNotNull( instance );
		Assert.isInstanceOf( instance, MockClass );
		Assert.isInstanceOf( instance, IMockInterface );
		Assert.isInstanceOf( instance, IAnotherMockInterface );
		
		Assert.equals( instance, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IMockInterface, "instance" ) );
		Assert.equals( instance, this._applicationAssembler.getApplicationContext( "applicationContext", ApplicationContext ).getInjector().getInstance( IAnotherMockInterface, "instance" ) );
	}

	@Test( "test if attribute" )
	public function testIfAttribute() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/ifAttribute.xml", null, null, ["production" => true, "test" => false, "release" => false] ) );
		Assert.equals( "hello production", this._locate( "message" ), "message value should equal 'hello production'" );
	}

	@Test( "test include with if attribute" )
	public function testIncludeWithIfAttribute() : Void
	{
		var variables = [ "production" => true, "test" => false, "release" => false ];
		this.build( BasicXmlReader.getXml( "context/xml/includeWithIfAttribute.xml", null, null, [ "production" => true, "test" => false, "release" => false ] ) );
		Assert.equals( "hello production", this._locate( "message" ), "message value should equal 'hello production'" );
	}

	@Test( "test include fails with if attribute" )
	public function testIncludeFailsWithIfAttribute() : Void
	{
		var variables = [ "production" => false, "test" => true, "release" => true ];
		this.build( BasicXmlReader.getXml( "context/xml/includeWithIfAttribute.xml", null, null,  [ "production" => false, "test" => true, "release" => true ] ) );
		Assert.methodCallThrows( NoSuchElementException, this._applicationContext.getCoreFactory(), this._locate, [ "message" ], "message value should equal 'hello production'" );
	}

	@Test( "test file preprocessor with Xml file" )
	public function testFilePreprocessorWithXmlFile() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/preprocessor.xml", null, [	"hello" 		=> "bonjour",
																					"contextName" 	=> 'applicationContext',
																					"context" 		=> 'name="${contextName}"',
																					"node" 			=> '<msg id="message" value="${hello}"/>' ] ) );

		Assert.equals( "bonjour", this._locate( "message" ), "message value should equal 'bonjour'" );
	}

	@Test( "test file preprocessor with Xml file and include" )
	public function testFilePreprocessorWithXmlFileAndInclude() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/preprocessorWithInclude.xml", null, [  "hello" 		=> "bonjour",
																								"contextName" 	=> 'applicationContext',
																								"context" 		=> 'name="${contextName}"',
																								"node" 			=> '<msg id="message" value="${hello}"/>' ] ) );

		try
        {
			Assert.equals( "bonjour", this._locate( "message" ), "message value should equal 'bonjour'" );
		}
		catch ( e : Exception )
        {
            Assert.fail( e.message, "Exception on this._locate( \"message\" ) call" );
        }
	}
	
	@Test( "test simple method call from another node" )
	public function testSimpleMethodCallFromAnotherNode() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/simpleMethodCallFromAnotherNode.xml" ) );

		var caller : MockCaller = this._locate( "caller" );
		Assert.isInstanceOf( caller, MockCaller, "" );
		Assert.deepEquals( [ "hello", "world" ], MockCaller.passedArguments, "" );
	}
	
	@Test( "test target sub property" )
	public function testTargetSubProperty() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/targetSubProperty.xml" ) );

		var mockObject : MockObjectWithRegtangleProperty = this._locate( "mockObject" );
		Assert.isInstanceOf( mockObject, MockObjectWithRegtangleProperty );
		Assert.equals( 1.5, mockObject.rectangle.x );
	}
	
	@Test( "test building mapping configuration" )
	public function testBuildingMappingConfiguration() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/mappingConfiguration.xml" ) );

		var config : MappingConfiguration = this._locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration );

		var injector = new Injector();
		config.configure( injector, null );

		Assert.isInstanceOf( injector.getInstance( IMockInterface ), MockClass );
		Assert.isInstanceOf( injector.getInstance( IAnotherMockInterface ), AnotherMockClass );
		Assert.equals( this._locate( "instance" ), injector.getInstance( IAnotherMockInterface ) );
	}
	
	@Test( "test building mapping configuration with map names" )
	public function testBuildingMappingConfigurationWithMapNames() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/mappingConfigurationWithMapNames.xml" ) );

		var config : MappingConfiguration = this._locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration );

		var injector = new Injector();
		config.configure( injector, null );

		Assert.isInstanceOf( injector.getInstance( IAnotherMockInterface, "name1" ),  MockClass );
		Assert.isInstanceOf( injector.getInstance( IAnotherMockInterface, "name2" ), AnotherMockClass );
	}
	
	@Test( "test building mapping configuration with singleton" )
	public function testBuildingMappingConfigurationWithSingleton() : Void
	{
		this.build( BasicXmlReader.getXml( "context/xml/mappingConfigurationWithSingleton.xml" ) );

		var config : MappingConfiguration = this._locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration );

		var injector = new Injector();
		config.configure( injector, null );

		var instance1 = injector.getInstance( IAnotherMockInterface, "name1" );
		Assert.isInstanceOf( instance1,  MockClass );
		
		var copyOfInstance1 = injector.getInstance( IAnotherMockInterface, "name1" );
		Assert.isInstanceOf( copyOfInstance1,  MockClass, "" );
		Assert.equals( instance1, copyOfInstance1 );
		
		var instance2 = injector.getInstance( IAnotherMockInterface, "name2" );
		Assert.isInstanceOf( instance2, AnotherMockClass );
		
		var copyOfInstance2 = injector.getInstance( IAnotherMockInterface, "name2" );
		Assert.isInstanceOf( copyOfInstance2,  AnotherMockClass );
		Assert.notEquals( instance2, copyOfInstance2 );
	}

	@Test( "test building mapping configuration with inject-into" )
	public function testBuildingMappingConfigurationWithInjectInto() : Void
	{
		this.build(  BasicXmlReader.getXml( "context/xml/mappingConfigurationWithInjectInto.xml" ) );

		var config : MappingConfiguration = this._locate( "config" );
		Assert.isInstanceOf( config, MappingConfiguration );

		var injector = new Injector();
		var domain = Domain.getDomain( 'BasicXmlReaderTest.testBuildingMappingConfigurationWithInjectInto' );
		injector.mapToValue( Domain, domain );
		
		config.configure( injector, null );

		var mock0 = injector.getInstance( IMockInjectee, "name1" );
		Assert.isInstanceOf( mock0,  MockInjectee );
		Assert.equals( domain, mock0.domain  );
		
		var mock1 = injector.getInstance( IMockInjectee, "name2" );
		Assert.isInstanceOf( mock1, MockInjectee );
		Assert.equals( domain, mock1.domain );
	}
}