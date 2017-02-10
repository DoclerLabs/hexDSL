# Flow DSL
Flow DSL is designed to mimic haxe language syntax and remove some Xml syntax weirdness.

## Introduction

Lets's begin first by summarizing why we want to have an alternative to xml protocol:

- Xml uses a tree hierarchy to define informations hierarchy, but hexMachina final grammar uses a flat hierarchy. So, Xml nodes structure (parent/children) brings more complexity than real advantages.
- Xml is verbose. To describe a simple information, like a primitive value assignment, you have to write tons of useless informations.
- Xml is hard to read by its node redundancy structure, and as well, for the reasons I listed above.
- Xml is not the best protocol to express complex engineering structures/informations. Let's take a common example: Class definition.

## Comparisons beetween both DSL: Flow and Xml

Now, let me add a few quick comparisons beetween the both DSL formats (Xml and Flow).

### Simple anonymous Object

<details>
<summary>Xml first:</summary>
```Xml
<test id="age" type="Int" value="45"/>
```
</details>

<details>
<summary>And now, the Flow version:</summary>
```haxe
age = 45;
```
</details>

### Simple hashmap

<details>
<summary>Xml first:</summary>
```Xml
<serviceLocator id="serviceLocator" type="hex.collection.HashMap<Class<Dynamic>, Class<Dynamic>">
    <item> 
        <key type="Class" value="mock.IMockService"/> 
        <value type="Class" value="mock.MockService"/>
    </item>
    <item> 
        <key type="Class" value="mock.IAnotherMockService"/> 
        <value type="Class" value="mock.AnotherMockService"/>
    </item>
</serviceLocator>
```
</details>

<details>
<summary>And now, the Flow version:</summary>
```haxe
serviceLocator = new hex.collection.HashMap<Class<IService>, Class<IService>>
([ 
    mock.IMockService => mock.MockService, 
    mock.IAnotherMockService => mock.AnotherMockService 
]);
```
</details>

## Use the basic Flow compiler

<details>
```haxe
<summary>Defining context</summary>
@context( name = 'myContextName' )
{
    myString = 'hello world';
}
```
</details>

<details>
<summary>File compilation</summary>
```haxe
var assembler = BasicFlowCompiler.compile( "context/flow/testBuildingString.flow" );
```
</details>

<details>
<summary>Locate ID</summary>
```haxe
factory = assembler.getApplicationContext( "myContextName", ApplicationContext ).getCoreFactory();
var myString = factory.locate( 'myString' );
```
</details>

## More Flow examples

### Primitive value assignment
<details>
<summary>Null value assignment to an ID</summary>
```haxe
@context( name = 'applicationContext' )
{
	value = null;
}
```
</details>

<details>
<summary>Boolean value assignment to an ID</summary>
```haxe
@context( name = 'applicationContext' )
{
	b = true;
}
```
</details>

<details>
<summary>String value assignment to an ID</summary>
```haxe
@context( name = 'applicationContext' )
{
	s = 'hello';
}
```
</details>

<details>
<summary>Int value assignment to an ID</summary>
```haxe
@context( name = 'applicationContext' )
{
	i = -3;
}
```
</details>

<details>
<summary>UInt value assignment to an ID</summary>
```haxe
@context( name = 'applicationContext' )
{
	i = 3;
}
```
</details>

<details>
<summary>Hexadecimal value assignment to an ID</summary>
```haxe
@context( name = 'applicationContext' )
{
	i = 0xFFFFFF;
}
```
</details>

### Instanciation and references
<details>
<summary>Anonymous object</summary>
```haxe
@context( name = 'applicationContext' )
{
	obj = { name: "Francis", age: 44, height: 1.75, isWorking: true, isSleeping: false };
}
```
</details>

<details>
<summary>Simple class instance</summary>
```haxe
@context( name = 'applicationContext' )
{
	instance = new hex.mock.MockClassWithoutArgument();
}
```
</details>

<details>
<summary>Simple class instance with primitive arguments passed to the constructor</summary>
```haxe
@context( name = 'applicationContext' )
{
	size = new hex.structures.Size( 10, 20 );
}
```
</details>

<details>
<summary>Building an instance with primitive references passed to its constructor</summary>
```haxe
@context( name = 'applicationContext' )
{
	x = 1;
	y = 2;
	position = new hex.structures.Point( x, y );
}
```
</details>

<details>
<summary>Building multiple instances and pass some of them as constructor arguments</summary>
```haxe
@context( name = 'applicationContext' )
{
	rect = new hex.mock.MockRectangle( rectPosition.x, rectPosition.y );
	rect.size = rectSize;
	
	rectSize = new hex.structures.Point( 30, 40 );
	
	rectPosition = new hex.structures.Point();
	rectPosition.x = 10;
	rectPosition.y = 20;
}
```
</details>

<details>
<summary>Building instances with multiple references passed to the constructor</summary>
```haxe
@context( name = 'applicationContext' )
{
	chat 			= new hex.mock.MockChat();
	receiver 		= new hex.mock.MockReceiver();
	proxyChat 		= new hex.mock.MockProxy( chat, chat.onTranslation );
	proxyReceiver 	= new hex.mock.MockProxy( receiver, receiver.onMessage );
}
```
</details>

<details>
<summary>Array filled with references</summary>
```haxe
@context( name = 'applicationContext' )
{
	fruits = new Array<hex.mock.MockFruitVO>( fruit0, fruit1, fruit2 );
	empty = [];
	text = [ "hello", "world" ];
	
	fruit0 = new hex.mock.MockFruitVO( "orange" );
	fruit1 = new hex.mock.MockFruitVO( "apple" );
	fruit2 = new hex.mock.MockFruitVO( "banana" );
}
```
</details>

<details>
<summary>Assign class reference to an ID</summary>
```haxe
@context( name = 'applicationContext' )
{
	RectangleClass = hex.mock.MockRectangle;
	classContainer = { AnotherRectangleClass: RectangleClass };
}
```
</details>

<details>
<summary>Hashmap filled with references</summary>
```haxe
@context( name = 'applicationContext' )
{
	fruits = new hex.collection.HashMap<Dynamic, hex.mock.MockFruitVO>
	([ 
		"0" => fruit0,
		1 => fruit1,
		stubKey => fruit2
	]);
	
	fruit0 = new hex.mock.MockFruitVO( "orange" );
	fruit1 = new hex.mock.MockFruitVO( "apple" );
	fruit2 = new hex.mock.MockFruitVO( "banana" );
	
	stubKey = new hex.structures.Point();
}
```
</details>

<details>
<summary>Get instance from static method</summary>
```haxe
@context( name = 'applicationContext' )
{
	gateway = "http://localhost/amfphp/gateway.php";
	service = hex.mock.MockServiceProvider.getInstance();
	service.setGateway( gateway );
}
```
</details>

<details>
<summary>Get instance from static method with arguments</summary>
```haxe
@context( name = 'applicationContext' )
{
	rect = hex.mock.MockRectangleFactory.getRectangle( 10, 20, 30, 40 );
}
```
</details>

<details>
<summary>Get instance from object's method call returned by static method</summary>
```haxe
@context( name = 'applicationContext' )
{
	point = hex.mock.MockPointFactory.getInstance().getPoint( 10, 20 );
}
```
</details>

<details>
<summary>Building multiple instances with arguments</summary>
```haxe
@context( name = 'applicationContext' )
{
	rect = new hex.mock.MockRectangle( 10, 20, 30, 40 );
	size = new hex.structures.Size( 15, 25 );
	position = new hex.structures.Point( 35, 45 );
}
```
</details>

### Injection and mapping
<details>
<summary>Inject into an instance</summary>
```haxe
@context( name = 'applicationContext' )
{
	@inject_into(a, b, c) instance = new hex.mock.MockClassWithInjectedProperty();
}
```
</details>

<details>
<summary>Create an instance using context's injector</summary>
```haxe
@context( name = 'applicationContext' )
{
	@injector_creation instance = new hex.mock.MockClassWithInjectedProperty();
}
```
</details>

<details>
<summary>Class instance with its abstract type mapped to context's injector</summary>
```haxe
@context( name = 'applicationContext' )
{
	@map_type( 'hex.mock.IMockInterface' ) instance = new hex.mock.MockClass();
}
```
</details>

<details>
<summary>Class instance mapped to 2 abstract types in context's injector</summary>
```haxe
@context( name = 'applicationContext' )
{
	@map_type( 	'hex.mock.IMockInterface',
				'hex.mock.IAnotherMockInterface' ) 
		instance = new hex.mock.MockClass();
}
```
</details>

<details>
<summary>HashMap with mapped type</summary>
```haxe
@context( name = 'applicationContext' )
{
	@map_type( 'hex.collection.HashMap<String, hex.mock.MockFruitVO>' ) 
	fruits = new hex.collection.HashMap<Dynamic, hex.mock.MockFruitVO>
	([ 
		"0" => fruit0,
		"1" => fruit1
	]);
	
	fruit0 = new hex.mock.MockFruitVO( "orange" );
	fruit1 = new hex.mock.MockFruitVO( "apple" );
}
```
</details>

<details>
<summary>Array instanciation mapped to abstract types thorugh context's injector</summary>
```haxe
@context( name = 'applicationContext' )
{
	@map_type( 'Array<Int>', 'Array<UInt>' ) intCollection = new Array<Int>();
	@map_type( 'Array<String>' ) stringCollection = new Array<String>();
}
```
</details>

<details>
<summary>Instances mapped to abstract types with type params</summary>
```haxe
@context( name = 'applicationContext' )
{
	i = 3;
	
	@map_type( 	'hex.mock.IMockInterfaceWithGeneric<Int>', 
				'hex.mock.IMockInterfaceWithGeneric<UInt>' ) 
		intInstance = new hex.mock.MockClassWithIntGeneric( i );
		
	@map_type( 'hex.mock.IMockInterfaceWithGeneric<String>' ) 
		stringInstance = new hex.mock.MockClassWithStringGeneric( 's' );
}
```
</details>

### Properties
<details>
<summary>Properties assignment</summary>
```haxe
@context( name = 'applicationContext' )
{
	rect = new hex.mock.MockRectangle();
	rect.size = size;
	
	size = new hex.structures.Point();
	size.x = width;
	size.y = height;
	
	width = 10;
	height = 20;
}
```
</details>

<details>
<summary>Assign class reference and static variable as object's property</summary>
```haxe
@context( name = 'applicationContext' )
{
	object = { property: hex.mock.MockClass.MESSAGE_TYPE };
	object2 = { property: hex.mock.MockClass };
	
	instance = new hex.mock.ClassWithConstantConstantArgument
		( hex.mock.MockClass.MESSAGE_TYPE );
}
```
</details>

### Method call
<details>
<summary>Simple method call on an instance</summary>
```haxe
@context( name = 'applicationContext' )
{
	caller = new hex.mock.MockCaller();
	caller.call( "hello", "world" );
}
```
</details>

<details>
<summary>Method call with argument typed from class with type paramemeters</summary>
```haxe
@context( name = 'applicationContext' )
{
	fruitsInterfaces = new Array<hex.mock.IMockFruit>( fruit0, fruit1, fruit2 );
	
	fruit0 = new hex.mock.MockFruitVO( "orange" );
	fruit1 = new hex.mock.MockFruitVO( "apple" );
	fruit2 = new hex.mock.MockFruitVO( "banana" );
	
	caller = new hex.mock.MockCaller();
	caller.callArray( fruitsInterfaces );
}
```
</details>

<details>
<summary>Building multiple instances and call methods on them</summary>
```haxe
@context( name = 'applicationContext' )
{
	rect = new hex.mock.MockRectangle();
	rect.size = rectSize;
	rect.offsetPoint( rectPosition );
	
	rectSize = new hex.structures.Point( 30, 40 );
	
	rectPosition = new hex.structures.Point();
	rectPosition.x = 10;
	rectPosition.y = 20;
	
	anotherRect = new hex.mock.MockRectangle();
	anotherRect.size = rectSize;
	anotherRect.reset();
}
```
</details>

### Static variable
<details>
<summary>Assign static variable to an ID</summary>
```haxe
@context( name = 'applicationContext' )
{
	constant = hex.mock.MockClass.MESSAGE_TYPE;
}
```
</details>

<details>
<summary>Pass static variable as a constructor argument</summary>
```haxe
@context( name = 'applicationContext' )
{
	instance = new hex.mock.ClassWithConstantConstantArgument
		( hex.mock.MockClass.MESSAGE_TYPE );
}
```
</details>

<details>
<summary>Pass a static variable as a method call argument</summary>
```haxe
@context( name = 'applicationContext' )
{
	instance = new hex.mock.MockMethodCaller();
	instance.call( hex.mock.MockMethodCaller.staticVar );
}
```
</details>

### Misc
<details>
<summary>Example with DSL preprocessing</summary>
```haxe
@context( ${context} )
{
	${node};
}
```
</details>

<details>
<summary>Parse and make Xml object</summary>
```haxe
@context( name = 'applicationContext' )
{
	fruits = Xml.parse
	(
		'<root>
			<node>orange</node>
			<node>apple</node>
			<node>banana</node>
		</root>'
	);
}
```
</details>

<details>
<summary>Parse Xml with custom parser and make custom instance</summary>
```haxe
@context( name = 'applicationContext' )
{
	fruits = Xml.parse
	(
		'<root>
			<node>orange</node>
			<node>apple</node>
			<node>banana</node>
		</root>'
	);
}
```
</details>

<details>
<summary>Conditional parsing</summary>
```haxe
@context( name = 'applicationContext' )
{
	#if ( test || release )
	message = "hello debug";
	#elseif production
	message = "hello production";
	#else
	message = "hello message";
	#end
}
```
</details>

<details>
<summary>Use a custom application context class</summary>
```haxe
@context( 
			name = 'applicationContext', 
			type = hex.ioc.parser.xml.context.mock.MockApplicationContext )
{
	test = 'Hola Mundo';
}
```
</details>