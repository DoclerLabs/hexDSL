# Xml DSL
Xml dsl is designed to use Xml syntax. The main advantage is that you can use the same syntax at runtime and at compile time.

## Use the basic Xml compiler

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
var assembler = BasicXmlCompiler.compile( "context/flow/testBuildingString.xml" );
```
</details>

<details>
<summary>Locate ID</summary>
```haxe
factory = assembler.getApplicationContext( "myContextName", ApplicationContext ).getCoreFactory();
var myString = factory.locate( 'myString' );
```
</details>

## More Xml examples

### Primitive value assignment
<details>
<summary>Null value assignment to an ID</summary>
```xml
<root name="applicationContext">
    <test id="value" type="null"/>
</root>
```
</details>

<details>
<summary>Boolean value assignment to an ID</summary>
```xml
<root name="applicationContext">
    <test id="b" type="Bool" value="true"/>
</root>
```
</details>

<details>
<summary>String value assignment to an ID</summary>
```xml
<root name="applicationContext">
    <test id="s" value="hello"/>
</root>
```
</details>

<details>
<summary>Int value assignment to an ID</summary>
```xml
<root name="applicationContext">
    <test id="i" type="Int" value="-3"/>
</root>
```
</details>

<details>
<summary>UInt value assignment to an ID</summary>
```xml
<root name="applicationContext">
    <test id="i" type="UInt" value="3"/>
</root>
```
</details>

<details>
<summary>Hexadecimal value assignment to an ID</summary>
```haxe
<root name="applicationContext">
    <test id="i" type="Int" value="0xFFFFFF"/>
</root>
```
</details>

### Instanciation and references
<details>
<summary>Anonymous object</summary>
```xml
<root name="applicationContext">
    <test id="obj" type="Object">
        <property name="name" value="Francis"/>
        <property name="age" type="Int" value="44"/>
        <property name="height" type="Float" value="1.75"/>
        <property name="isWorking" type="Bool" value="true"/>
        <property name="isSleeping" type="Bool" value="false"/>
    </test>
</root>
```
</details>

<details>
<summary>Simple class instance</summary>
```xml
<root name="applicationContext">
    <bean id="instance" type="hex.mock.MockClassWithoutArgument"/>
</root>
```
</details>

<details>
<summary>Simple class instance with primitive arguments passed to the constructor</summary>
```xml
<root name="applicationContext">
    <bean id="size" type="hex.structures.Size">
        <argument type="Int" value="10"/>
        <argument type="Int" value="20"/>
    </bean>
</root>
```
</details>

<details>
<summary>Building an instance with primitive references passed to its constructor</summary>
```xml
<root name="applicationContext">
	
    <x id="x" type="Int" value="1"/>
    <y id="y" type="Int" value="2"/>

    <position id="position" type="hex.structures.Point">
        <argument ref="x" />
        <argument ref="y" />
    </position>
	
</root>
```
</details>

<details>
<summary>Building multiple instances and pass some of them as constructor arguments</summary>
```xml
<root name="applicationContext">
	
    <rectangle id="rect" type="hex.mock.MockRectangle">
        <argument ref="rectPosition.x"/>
        <argument ref="rectPosition.y"/>
        <property name="size" ref="rectSize" />
    </rectangle>

    <size id="rectSize" type="hex.structures.Point">
        <argument type="Int" value="30"/>
        <argument type="Int" value="40"/>
    </size>

    <position id="rectPosition" type="hex.structures.Point">
        <property type="Int" name="x" value="10"/>
        <property type="Int" name="y" value="20"/>
    </position>
	
</root>
```
</details>

<details>
<summary>Building instances with multiple references passed to the constructor</summary>
```xml
<root name="applicationContext">
	
	<chat id="chat" type="hex.mock.MockChat"/>
    <receiver id="receiver" type="hex.mock.MockReceiver"/>
	
	<proxy id="proxyChat" type="hex.mock.MockProxy">
        <argument ref="chat" />
        <argument ref="chat.onTranslation"/>
    </proxy>

    <proxy id="proxyReceiver" type="hex.mock.MockProxy">
        <argument ref="receiver" />
        <argument ref="receiver.onMessage"/>
    </proxy>
	
</root>
```
</details>

<details>
<summary>Array filled with references</summary>
```haxe
<root name="applicationContext">

    <collection id="fruits" type="Array<hex.mock.MockFruitVO>">
        <argument ref="fruit0" />
        <argument ref="fruit1" />
        <argument ref="fruit2" />
    </collection>
	
	<collection id="empty" type="Array<Dynamic>"/>
	
	<collection id="text" type="Array<String>">
        <argument value="hello" />
        <argument value="world" />
    </collection>

    <fruit id="fruit0" type="hex.mock.MockFruitVO"><argument value="orange"/></fruit>
    <fruit id="fruit1" type="hex.mock.MockFruitVO"><argument value="apple"/></fruit>
    <fruit id="fruit2" type="hex.mock.MockFruitVO"><argument value="banana"/></fruit>

</root>
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
<summary>Array instanciation mapped to abstact types thorugh context's injector</summary>
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