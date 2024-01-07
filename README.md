# GDSerialize: Godot 4 schema-based serializer (JSON schema included)

Did you ever want to make sure that your JSON files actually have the correct data in them? Then
this library is for you.

*Note:* This library requires the Something Pink [gderror](https://github.com/SomethingPinkGmbH/gderror) and
[gdtype](https://github.com/SomethingPinkGmbH/gdtype) addons.

## Why?!

If you want to provide a mod API or make HTTP requests from your Godot game, having a schema will
cut down on bugs. Furthermore, the generated JSON schema can help generate code for the same data
format in other programming languages.

## Installation

Download this repository as a ZIP and unpack it into the `addons` folder of your project.
You can (but don't have to) active the plugin.

## Building a schema

As a first step, you should build a data structure that you want to serialize. The easiest way 
to achieve this is to create classes that have names. For example:

```gdscript
class_name Player extends Object

var name: String
```

So far so good, now we need to define a *serializer* that describes this object.
(Unfortunately, we can't auto-generate the serializer because GDScript doesn't have enough
reflection capabilities.)

Let's add the serializer to the class above:

```gdscript
static var SERIALIZER = ObjectSerializer.new(
	# Pass the name of the object here.
	"Player",
	# Pass the class name in here.
	Player,
	{
		# Describe the fields here.
		"name": StringSerializer.new(
			1, 255
		),
	}
)
```

That's it! Now you can create a JSON-serialized version of your object like this:

```gdscript
var my_player = Player.new(
	"Jane Doe"
)
var serialized_data = Player.SERIALIZER.serialize(my_player)
if serialized_data.error:
	print(serialized_data.error)
else:
	var json = JSON.stringify(serialized_data.value)
	print(json)
```

Conversely, if you want to turn JSON-serialized data into a Godot object, you can do it like this:

```gdscript
var serialized_data = JSON.parse("{\"name\":\"John Doe\"}")
var unserialized_data = Player.SERIALIZER.unserialize(serialized_data)
if unserialized_data.error:
	print(unserialized_data.error)
else:
	var player: Player = unserialized_data.value
	print(player.name)
```

Of course, if you pass syntactically correct data with incorrect fields, the above code will print
an error.

## Serializers

The following serializers are available in this library:

| Serializer | Native data type |
|------------|------------------|
| [`ArraySerializer`](#arrayserializer) | `Array` |
| [`BinarySerializer`](#binaryserializer) | `PackedByteArray` |
| [`BoolSerializer`](#boolserializer) | `bool` |
| [`DictionarySerializer`](#dictionaryserializer) | `Dictionary` |
| [`EnumSerializer`](#enumserializer) | enums\* |
| [`FloatSerializer`](#floatserializer) | `float` |
| [`IntSerializer`](#intserializer) | `int` |
| [`ObjectSerializer`](#objectserializer) | `class` |
| [`StringSerializer`](#stringserializer) | `String` |
| [`OptionalSerializer`](#optionalserializer) | depending on the backing serializer |
| [`UUIDSerializer`](#uuidserializer) | `String` |

\*: Enums are represented as dictionaries with string keys and int values in GDScript.

### `ArraySerializer`

The `ArraySerializer` can serialize an array of a specific type. It does not support arrays of mixed
types. You can create it like this:

```gdscript
static var SERIALIZER = ArraySerializer.new(
	# Pass the contained type in here.
	StringSerializer.new()
)
```

### `BinarySerializer`

The `BinarySerializer` serializes `PackedByteArray` values into strings with a specified encoding.
Currently, it only supports base 64 encoding. You can create it like this:

```gdscript
static var SERIALIZER = BinarySerializer.new(BinarySerializer.Base64ContentEncoder.new())
```

**Note:** You can implement your own `ContentEncoder`:

```gdscript
class YourContentEncoder extends BinarySerializer.ContentEncoder:
	func encode(data: PackedByteArray) -> String:
		#...

	func decode(data: String) -> PackedByteArray:
		#...

	func json_schema() -> String:
		#...
```

### `BoolSerializer`

The `BoolSerializer` serializes bool values and does not accept other data types. You can create it
like this:

```gdscript
static var SERIALIZER = BoolSerializer.new()
```

### `DictionarySerializer`

The `DictionarySerializer` serializes dictionaries of a specific key and value type. It also
supports checking if the dictionary contains a specific number of items. You can create it like
this:

```gdscript
static var SERIALIZER = DictionarySerializer.new(
	# Pass the key type here:
	StringSerializer.new(),
	# Pass the value type here:
	IntSerializer.new(),
	# Minimum number of items, can be omitted:
	3,
	# Maximum number of items, can be omitted:
	5
)
```

### `EnumSerializer`

The `EnumSerializer` serializes enums that only accept specific values. The serializer has two
modes: it either serializes the enum to its integer value, or to its string name. You can create
the serializer like this:

```gdscript
enum Fruit{Apple=1, Banana=2}

static var SERIALIZER = EnumSerializer.new(
	Fruit,
	# KEY: serializes Apple as 1.
	# VALUE: serializes Apple as "Apple"
	EnumSerializer.Method.KEY
)
```

### `FloatSerializer`

The `FloatSerializer` serializes floating point (decimal) numbers. It does not support any other
data types at the moment. It does, however, support minimum and maximum values. You can create a 
float serializer like this:

```gdscript
static var SERIALIZER = FloatSerializer.new(
	# Minimum, can be omitted:
	1.0,
	# Maximum, can be omitted:
	2.0
)
```

### `IntSerializer`

The `IntSerializer` serializes integer (whole) numbers. It does not support any other
data types at the moment. It does, however, support minimum and maximum values. You can create an
int serializer like this:

```gdscript
static var SERIALIZER = IntSerializer.new(
	# Minimum, can be omitted:
	1,
	# Maximum, can be omitted:
	2
)
```

### `ObjectSerializer`

The `ObjectSerializer` serializes classes into dictionaries and back. In order to use it, you must
create the class as a separate `.gd` file with an explicit class name. You can create the 
serializer like this:

```gdscript
class_name Player extends Object

var name: string

static var SERIALIZER = ObjectSerializer.new(
	# Pass the name of the class as a string here
	"Player",
	# Pass the class name in here.
	Player,
	{
		# Describe the fields here. Fields that are not described will not be serialized.
		"name": StringSerializer.new(
			1, 255
		),
	}
)
```

**Warning:** When specifying the array variables in your object, don't use `Array[int]`. Use the
simple `Array` instead. Using the former type will lead to silent bugs due to how Godot works.

### `StringSerializer`

The `StringSerializer` serializes string values. It also supports checking minimum and maximum
length, as well as regular expressions. You can create a string serializer like this:

```gdscript
static var SERIALIZER = StringSerializer.new(
	# Minimum length, optional:
	1,
	# Maximum length, optional:
	5,
	# Regular expression, optional:
	"^[a-zA-Z]+$"
)
```

### `OptionalSerializer`

The `OptionalSerializer` allows for `null` values to be serialized/unserialized. You can create
it like this:

```gdscript
static var SERIALIZER = OptionalSerializer.new(
	# Backing serializer:
	IntSerializer.new(),
	# Default value, optional:
	42
)
```

This serializer also allows for fields to be completely omitted from objects.

### `UUIDSerializer`

The `UUIDSerializer` is a special version of the `StringSerializer` that matches a UUID-style
string. It also provides the `format: "uuid"` specifier in the JSON schema. You can use it
like this:
	
```gdscript
static var SERIALIZER = UUIDSerializer.new()
```

## JSON schema generation

This library is capable of generating a JSON schema:

```gdscript
print(JSONSchema.from_serializer(IntSerializer.new(), "https://example.com/schema.json"))
```

You can also add extra documentation and examples to your serializers. This information will show
up in the generated JSON schema document:

```gdscript
static var SERIALIZER = DocumentedSerializer.new(
	"Title here",
	"Longer description here",
	# Actual serializer here:
	IntSerializer.new(),
	# Examples here:
	[
		42
	]
)
```

By default, all object serializers place objects into the `defs` section of the JSON schema. Other
types are inlined. If you want to place other types in the `defs` section, you can use the
`ReferencedSerializer` to do so:

```gdscript
static var SERIALIZER = ReferencedSerializer.new("SomeName", IntSerializer.new())
```

