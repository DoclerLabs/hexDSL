# Xml DSL
Xml DSL, as you can guess, is designed to use Xml syntax for building your application. The main advantage is that you can use the same syntax/files at runtime and at compiletime as shown below.
- To compile DSL (and generate code for targeted platform at compiletime), use `BasicXmlCompiler` class.
- To read DSL at runtime, use `BasicXmlReader` class.

## Use the basic Xml compiler

<details>
<summary>Defining context</summary>

```xml
<root name="myContextName">
    <test id="myString" value="hello world"/>
</root>
```
</details>

<details>
<summary>File compilation</summary>

```haxe
var assembler = BasicXmlCompiler.compile( "context/xml/testBuildingString.xml" );
```
</details>

<details>
<summary>Locate ID</summary>

```haxe
factory = assembler.getApplicationContext( "myContextName", ApplicationContext ).getCoreFactory();
var myString = factory.locate( 'myString' );
```
</details>

## Use the basic Xml reader

<details>
<summary>Defining context</summary>

```xml
<root name="myContextName">
    <test id="myString" value="hello world"/>
</root>
```
</details>

<details>
<summary>File reading</summary>

```haxe
var assembler = BasicXmlReader.read( "context/xml/testBuildingString.xml" );
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

```xml
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

```xml
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

```xml
<root name="applicationContext">

    <RectangleClass id="RectangleClass" type="Class" value="hex.mock.MockRectangle"/>

    <test id="classContainer" type="Object">
        <property name="AnotherRectangleClass" ref="RectangleClass"/>
    </test>

</root>
```
</details>

<details>
<summary>Hashmap filled with references</summary>

```xml
<root name="applicationContext">
	
    <collection id="fruits" type="hex.collection.HashMap<Dynamic, hex.mock.MockFruitVO>">
        <item> <key value="0"/> <value ref="fruit0"/></item>
        <item> <key type="Int" value="1"/> <value ref="fruit1"/></item>
        <item> <key ref="stubKey"/> <value ref="fruit2"/></item>
    </collection>
	
    <fruit id="fruit0" type="hex.mock.MockFruitVO"><argument value="orange"/></fruit>
    <fruit id="fruit1" type="hex.mock.MockFruitVO"><argument value="apple"/></fruit>
    <fruit id="fruit2" type="hex.mock.MockFruitVO"><argument value="banana"/></fruit>
    <point id="stubKey" type="hex.structures.Point"/>
	
</root>
```
</details>

<details>
<summary>Get instance from static method</summary>

```xml
<root name="applicationContext">
	
    <gateway id="gateway" value="http://localhost/amfphp/gateway.php"/>

    <service id="service" type="hex.mock.MockServiceProvider" static-call="getInstance">
        <method-call name="setGateway">
            <argument ref="gateway" />
        </method-call>
    </service>
	
</root>
```
</details>

<details>
<summary>Get instance from static method with arguments</summary>

```xml
<root name="applicationContext">
	
    <rectangle id="rect" type="hex.mock.MockRectangleFactory" static-call="getRectangle">
        <argument type="Int" value="10"/><argument type="Int" value="20"/>
        <argument type="Int" value="30"/><argument type="Int" value="40"/>
    </rectangle>
	
</root>
```
</details>

<details>
<summary>Get instance from object's method call returned by static method</summary>

```xml
<root name="applicationContext">
	
    <point id="point" type="hex.mock.MockPointFactory" static-call="getInstance" factory-method="getPoint">
        <argument type="Int" value="10"/>
        <argument type="Int" value="20"/>
    </point>
	
</root>
```
</details>

<details>
<summary>Building multiple instances with arguments</summary>

```xml
<root name="applicationContext">
	
	<rectangle id="rect" type="hex.mock.MockRectangle">
		<argument type="Int" value="10"/>
        <argument type="Int" value="20"/>
		<argument type="Int" value="30"/>
        <argument type="Int" value="40"/>
    </rectangle>

    <bean id="size" type="hex.structures.Size">
        <argument type="Int" value="15"/>
        <argument type="Int" value="25"/>
    </bean>
	
	<bean id="position" type="hex.structures.Point">
        <argument type="Int" value="35"/>
        <argument type="Int" value="45"/>
    </bean>
	
</root>
```
</details>

### Injection and mapping
<details>
<summary>Inject into an instance</summary>

```xml
<root name="applicationContext">
    <instance id="instance" type="hex.mock.MockClassWithInjectedProperty" inject-into="true"/>
</root>
```
</details>

<details>
<summary>Create an instance using context's injector</summary>

```xml
<root name="applicationContext">
    <instance id="instance" type="hex.mock.MockClassWithInjectedProperty" injector-creation="true"/>
</root>
```
</details>

<details>
<summary>Class instance with its abstract type mapped to context's injector</summary>

```xml
<root name="applicationContext">

    <module id="instance" type="hex.mock.MockClass" map-type="hex.mock.IMockInterface"/>

</root>
```
</details>

<details>
<summary>Class instance mapped to 2 abstract types in context's injector</summary>

```xml
<root name="applicationContext">
    <module id="instance" type="hex.mock.MockClass" map-type="hex.mock.IMockInterface; hex.mock.IAnotherMockInterface"/>
</root>
```
</details>

<details>
<summary>HashMap with mapped type</summary>

```xml
<root name="applicationContext">
	
    <collection id="fruits" type="hex.collection.HashMap" map-type="hex.collection.HashMap<String, hex.mock.MockFruitVO>">
        <item> <key value="0"/> <value ref="fruit0"/></item>
        <item> <key value="1"/> <value ref="fruit1"/></item>
    </collection>
	
    <fruit id="fruit0" type="hex.mock.MockFruitVO"><argument value="orange"/></fruit>
    <fruit id="fruit1" type="hex.mock.MockFruitVO"><argument value="apple"/></fruit>
	
</root>
```
</details>

<details>
<summary>Array instanciation mapped to abstract types thorugh context's injector</summary>

```xml
<root name="applicationContext">
    <test id="intCollection" type="Array<Int>" map-type="Array<Int>; Array<UInt>"/>
    <test id="stringCollection" type="Array<String>" map-type="Array<String>"/>
</root>
```
</details>

<details>
<summary>Instances mapped to abstract types with type params</summary>

```xml
<root name="applicationContext">
   
    <i id="i"  type="Int"  value="3"/>
	<intInstance id="intInstance" type="hex.mock.MockClassWithIntGeneric" map-type="hex.mock.IMockInterfaceWithGeneric<Int>; hex.mock.IMockInterfaceWithGeneric<UInt>">
		<argument ref="i"/>
	</intInstance>
	
	<s id="s"  value="test"/>
	<stringInstance id="stringInstance" type="hex.mock.MockClassWithStringGeneric" map-type="hex.mock.IMockInterfaceWithGeneric<String>">
		<argument ref="s"/>
	</stringInstance>
	
</root>
```
</details>

### Properties
<details>
<summary>Properties assignment</summary>

```xml
<root name="applicationContext">
	
	<rectangle id="rect" type="hex.mock.MockRectangle">
        <property name="size" ref="size" />
    </rectangle>
	
    <size id="size" type="hex.structures.Point">
        <property name="x" ref="width" />
        <property name="y" ref="height" />
    </size>
	
	<bean id="width" type="Int" value="10"/>
	<bean id="height" type="Int" value="20"/>

</root>
```
</details>

<details>
<summary>Assign class reference and static variable as object's property</summary>

```xml
<root name="applicationContext">

    <object id="object" type="Object">
        <property name="property" static-ref="hex.mock.MockClass.MESSAGE_TYPE"/>
    </object>
	
	<object id="object2" type="Object">
        <property name="property" type="Class" value="hex.mock.MockClass"/>
    </object>

    <instance id="instance" type="hex.mock.ClassWithConstantConstantArgument">
        <argument static-ref="hex.mock.MockClass.MESSAGE_TYPE"/>
    </instance>

</root>
```
</details>

### Method call
<details>
<summary>Simple method call on an instance</summary>

```xml
<root name="applicationContext">

    <caller id="caller" type="hex.mock.MockCaller">
        <method-call name="call">
            <argument value="hello"/>
            <argument value="world"/>
        </method-call>
    </caller>

</root>
```
</details>

<details>
<summary>Method call with argument typed from class with type paramemeters</summary>

```xml
<root name="applicationContext">

    <caller id="caller" type="hex.mock.MockCaller">
        <method-call name="callArray">
            <argument ref="fruitsInterfaces"/>
        </method-call>
    </caller>

    <collection id="fruitsInterfaces" type="Array<hex.mock.IMockFruit>">
        <argument ref="fruit0" />
        <argument ref="fruit1" />
        <argument ref="fruit2" />
    </collection>
	
    <fruit id="fruit0" type="hex.mock.MockFruitVO"><argument value="orange"/></fruit>
    <fruit id="fruit1" type="hex.mock.MockFruitVO"><argument value="apple"/></fruit>
    <fruit id="fruit2" type="hex.mock.MockFruitVO"><argument value="banana"/></fruit>
	
</root>
```
</details>

<details>
<summary>Building multiple instances and call methods on them</summary>

```xml
<root name="applicationContext">
	
    <rectangle id="rect" type="hex.mock.MockRectangle">
        <property name="size" ref="rectSize" />
        <method-call name="offsetPoint">
            <argument ref="rectPosition"/>
        </method-call>
	</rectangle>

    <size id="rectSize" type="hex.structures.Point">
        <argument type="Int" value="30"/>
        <argument type="Int" value="40"/>
    </size>

    <position id="rectPosition" type="hex.structures.Point">
        <property type="Int" name="x" value="10"/>
        <property type="Int" name="y" value="20"/>
    </position>

    <rectangle id="anotherRect" type="hex.mock.MockRectangle">
        <property name="size" ref="rectSize" />
        <method-call name="reset"/>
    </rectangle>
	
</root>
```
</details>

### Static variable
<details>
<summary>Assign static variable to an ID</summary>

```xml
<root name="applicationContext">
    <constant id="constant" static-ref="hex.mock.MockClass.MESSAGE_TYPE"/>
</root>
```
</details>

<details>
<summary>Pass static variable as a constructor argument</summary>

```xml
<root name="applicationContext">

    <instance id="instance" type="hex.mock.ClassWithConstantConstantArgument">
        <argument static-ref="hex.mock.MockClass.MESSAGE_TYPE"/>
    </instance>

</root>
```
</details>

<details>
<summary>Pass a static variable as a method call argument</summary>

```xml
<root name="applicationContext">

    <instance id="instance" type="hex.mock.MockMethodCaller">
		<method-call name="call">
			<argument static-ref="hex.mock.MockMethodCaller.staticVar"/>
		</method-call>
    </instance>

</root>
```
</details>

### Misc
<details>
<summary>Example with DSL preprocessing</summary>

```xml
<root ${context}>

    ${node}

</root>
```
</details>

<details>
<summary>Parse and make Xml object</summary>

```xml
<root name="applicationContext">

    <data id="fruits" type="XML">
        <root>
            <node>orange</node>
            <node>apple</node>
            <node>banana</node>
        </root>
    </data>

</root>
```
</details>

<details>
<summary>Parse Xml with custom parser and make custom instance</summary>

```xml
<root name="applicationContext">

    <data id="fruits" type="XML" parser-class="hex.mock.MockXmlParser">
        <root>
            <node>orange</node>
            <node>apple</node>
            <node>banana</node>
        </root>
    </data>

</root>
```
</details>

<details>
<summary>Conditional parsing</summary>

```xml
<root name="applicationContext">

    <msg id="message" value="hello debug" if="test,release"/>
    <msg id="message" value="hello production" if="production"/>

</root>
```
</details>

<details>
<summary>Use a custom application context class</summary>

```xml
<root name="applicationContext" type="hex.ioc.parser.xml.context.mock.MockApplicationContext">
	<test id="test" value="Hola Mundo"/>
</root>
```
</details>