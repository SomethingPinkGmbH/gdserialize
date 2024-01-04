extends SerializeTest

class TestObject:
	var a: int

func test_null():
	var serializer = IntSerializer.new()
	assert_error(serializer.serialize(null), ERR_INVALID_DATA)
	assert_error(serializer.unserialize(null), ERR_INVALID_DATA)
	
	var optional_serializer = OptionalSerializer.new(serializer)
	assert_no_error(optional_serializer.serialize(null))
	assert_no_error(optional_serializer.unserialize(null))

func test_default_value():
	var optional_serializer = OptionalSerializer.new(IntSerializer.new(), 42)
	assert_eq(optional_serializer.serialize(null).value, 42)
	assert_eq(optional_serializer.unserialize(null).value, 42)

func test_object():
	var serializer = ObjectSerializer.new(
		"TestObject",
		TestObject,
		{
			"a": OptionalSerializer.new(
				IntSerializer.new()
			)
		}
	)
	
	var result = serializer.unserialize({})
	assert_no_error(result)
	assert_eq(result.value.a, 0)

func test_array():
	var serializer = ArraySerializer.new(
		OptionalSerializer.new(
			IntSerializer.new()
		)
	)
	var result = serializer.unserialize([null])
	assert_no_error(result)
	assert_null(result.value[0])
