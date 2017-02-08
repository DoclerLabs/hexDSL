# Flow DSL
Flow dsl is a DSL designed to mimic haxe language syntax and remove some Xml syntax weirdness.

Lets's begin first by summarizing why we want to have an alternative to xml protocol:

- Xml uses a tree hierarchy to define informations hierarchy, but hexMachina final grammar uses a flat hierarchy. So, Xml nodes structure (parent/children) brings more complexity than real advantages.
- Xml is verbose. To describe a simple information, like a primitive value assignment, you have to write tons of useless informations.
- Xml is hard to read by its node redundancy structure, and as well, for the reasons I listed above.
- Xml is not the best protocol to express complex engineering structures/informations. Let's take a common example: Class definition.

Now, let me add a few quick comparisons beetween the both DSL formats (Xml and Flow).

## Simple anonymous Object

Xml first:
```Xml
<test id="age" type="Int" value="45"/>
```

And now, the Flow version:
```haxe
age = 45;
```

## Simple hashmap

Xml first:
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

And now, the Flow version:
```haxe
serviceLocator = new hex.collection.HashMap<Class<Dynamic>, Class<Dynamic>>
([ 
    mock.IMockService => mock.MockService, 
    mock.IAnotherMockService => mock.AnotherMockService 
]);
```

## More Flow examples

### Null value assignment to an ID
```haxe
@context( name = 'applicationContext' )
{
	value = null;
}
```

### Boolean value assignment to an ID
```haxe
@context( name = 'applicationContext' )
{
	b = true;
}
```

### String value assignment to an ID
```haxe
@context( name = 'applicationContext' )
{
	s = 'hello';
}
```

### Int value assignment to an ID
```haxe
@context( name = 'applicationContext' )
{
	i = -3;
}
```

### UInt value assignment to an ID
```haxe
@context( name = 'applicationContext' )
{
	i = 3;
}
```

### Hexadecimal value assignment to an ID
```haxe
@context( name = 'applicationContext' )
{
	i = 0xFFFFFF;
}
```

### Anonymous object
```haxe
@context( name = 'applicationContext' )
{
	obj = { name: "Francis", age: 44, height: 1.75, isWorking: true, isSleeping: false };
}
```

### Use a custom application context class
```haxe
@context( 
			name = 'applicationContext', 
			type = hex.ioc.parser.xml.context.mock.MockApplicationContext )
{
	test = 'Hola Mundo';
}
```

### Assign an array filled with references to an ID
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

### Assign class reference to an ID
```haxe
@context( name = 'applicationContext' )
{
	RectangleClass = hex.mock.MockRectangle;
	classContainer = { AnotherRectangleClass: RectangleClass };
}
```

### Assign an hashmap filled with references to an ID
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

### HashMap with mapped type
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

### Conditional parsing
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

### Inject into an instance
```haxe
@context( name = 'applicationContext' )
{
	@inject_into(a, b, c) instance = new hex.mock.MockClassWithInjectedProperty();
}
```

### Create an instance using context's injector
```haxe
@context( name = 'applicationContext' )
{
	@injector_creation instance = new hex.mock.MockClassWithInjectedProperty();
}
```

### Properties assignment
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

### Get instance from static method
```haxe
@context( name = 'applicationContext' )
{
	gateway = "http://localhost/amfphp/gateway.php";
	service = hex.mock.MockServiceProvider.getInstance();
	service.setGateway( gateway );
}
```

### Get instance from static method with arguments
```haxe
@context( name = 'applicationContext' )
{
	rect = hex.mock.MockRectangleFactory.getRectangle( 10, 20, 30, 40 );
}
```

### Get instance from object's method call returned by static method
```haxe
@context( name = 'applicationContext' )
{
	point = hex.mock.MockPointFactory.getInstance().getPoint( 10, 20 );
}
```

### Class instance with its abstract type mapped to context's injector
```haxe
@context( name = 'applicationContext' )
{
	@map_type( 'hex.mock.IMockInterface' ) instance = new hex.mock.MockClass();
}
```

### Method call with argument typed from class with type paramemeters
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

### Class instance mapped to 2 abstract types in context's injector
```haxe
@context( name = 'applicationContext' )
{
	@map_type( 	'hex.mock.IMockInterface',
				'hex.mock.IAnotherMockInterface' ) 
		instance = new hex.mock.MockClass();
}
```

### Building multiple instances with arguments
```haxe
@context( name = 'applicationContext' )
{
	rect = new hex.mock.MockRectangle( 10, 20, 30, 40 );
	size = new hex.structures.Size( 15, 25 );
	position = new hex.structures.Point( 35, 45 );
}
```

### Building multiple instances and call methods on them
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

### Building multiple instances and pass some of them as constructor arguments
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

### Example with DSL preprocessing
```haxe
@context( ${context} )
{
	${node};
}
```

### Simple class instance
```haxe
@context( name = 'applicationContext' )
{
	instance = new hex.mock.MockClassWithoutArgument();
}
```

### Simple class instance with primitive arguments passed to the constructor
```haxe
@context( name = 'applicationContext' )
{
	size = new hex.structures.Size( 10, 20 );
}
```

### Simple method call on an instance
```haxe
@context( name = 'applicationContext' )
{
	caller = new hex.mock.MockCaller();
	caller.call( "hello", "world" );
}
```

### Building instances with multiple references passed to the constructor
```haxe
@context( name = 'applicationContext' )
{
	chat 			= new hex.mock.MockChat();
	receiver 		= new hex.mock.MockReceiver();
	proxyChat 		= new hex.mock.MockProxy( chat, chat.onTranslation );
	proxyReceiver 	= new hex.mock.MockProxy( receiver, receiver.onMessage );
}
```

### Building an instance with primitive references passed to its constructor
```haxe
@context( name = 'applicationContext' )
{
	x = 1;
	y = 2;
	position = new hex.structures.Point( x, y );
}
```

### Assign static variable to an ID
```haxe
@context( name = 'applicationContext' )
{
	constant = hex.mock.MockClass.MESSAGE_TYPE;
}
```

### Pass static variable as a constructor argument
```haxe
@context( name = 'applicationContext' )
{
	instance = new hex.mock.ClassWithConstantConstantArgument
		( hex.mock.MockClass.MESSAGE_TYPE );
}
```

### Pass a static variable as a method call argument
```haxe
@context( name = 'applicationContext' )
{
	instance = new hex.mock.MockMethodCaller();
	instance.call( hex.mock.MockMethodCaller.staticVar );
}
```

### Assign class reference and static variable as object property
```haxe
@context( name = 'applicationContext' )
{
	object = { property: hex.mock.MockClass.MESSAGE_TYPE };
	object2 = { property: hex.mock.MockClass };
	
	instance = new hex.mock.ClassWithConstantConstantArgument
		( hex.mock.MockClass.MESSAGE_TYPE );
}
```

### Array instanciation mapped to abstact types thorugh context's injector
```haxe
@context( name = 'applicationContext' )
{
	@map_type( 'Array<Int>', 'Array<UInt>' ) intCollection = new Array<Int>();
	@map_type( 'Array<String>' ) stringCollection = new Array<String>();
}
```

### Instances mapped to abstract types with type params
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

### Parse and make Xml object
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

### Parse Xml with custom parser and make custom instance
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
