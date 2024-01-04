extends SerializeTest

class TestObject:
	var a: int

func test_object_serialization():
	var serializer = autofree(ObjectSerializer.new(
		"TestObject",
		TestObject,
		{
			"a": IntSerializer.new()
		}
	))
	
	var original = autofree(TestObject.new())
	original.a = 42
	
	var serialization_result = autofree(serializer.serialize(original))
	assert_true(serialization_result.is_ok(), "Serialization failed: %s"%serialization_result.error)
	assert_eq(serialization_result.value.size(), 1)
	assert_eq(serialization_result.value["a"], 42)
	
	var unserialization_result = autofree(serializer.unserialize(serialization_result.value))
	assert_true(unserialization_result.is_ok(), "Unserialization failed: %s"%unserialization_result.error)
	assert_true(unserialization_result.value is TestObject)
	assert_eq(unserialization_result.value.a, 42)

func test_null():
	var serializer = autofree(ObjectSerializer.new(
		"TestObject",
		TestObject,
		{
			"a": IntSerializer.new()
		}
	))
	
	assert_error(serializer.serialize(null), ERR_INVALID_DATA)
