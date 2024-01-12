extends SerializeTest

class A extends RefCounted:
	var foo: String

class B extends RefCounted:
	var bar: String

func test_object_serialization():
	var serializer = OneOfSerializer.new(
		"_type",
		StringSerializer.new(),
		false,
		{
			"a": ObjectSerializer.new(
				"A",
				A,
				{
					"foo": StringSerializer.new()
				}
			),
			"b": ObjectSerializer.new(
				"B",
				B,
				{
					"bar": StringSerializer.new()
				}
			)
		}
	)
	
	var unserialized = serializer.unserialize({"_type": "a", "foo": "Hello world!"})
	if !assert_no_error(unserialized):
		return
	assert_true(is_instance_of(unserialized.value, A))
	assert_eq(unserialized.value.foo, "Hello world!")
	
	var reserialized = serializer.serialize(unserialized.value)
	assert_false(reserialized.is_error(), str(reserialized.error))
	assert_eq(reserialized.value["_type"], "a")
	assert_eq(reserialized.value["foo"], "Hello world!")
