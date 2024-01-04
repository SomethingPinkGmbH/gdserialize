extends SerializeTest

func test_float_serialization():
	var serializer: FloatSerializer = autofree(FloatSerializer.new())
	
	var result = serializer.serialize(0.0)
	assert_no_error(result)
	assert_eq(result.value, 0.0)
	
	result = serializer.serialize(1.0)
	assert_true(result.is_ok())
	assert_eq(result.value, 1.0)
	
	result = serializer.serialize(-1.0)
	assert_true(result.is_ok())
	assert_eq(result.value, -1.0)
	
func test_float_unserialization():
	var serializer: FloatSerializer = autofree(FloatSerializer.new())
	
	var result = serializer.unserialize(0)
	assert_no_error(result)
	assert_eq(result.value, 0.0)
	
	result = serializer.unserialize(1)
	assert_no_error(result)
	assert_eq(result.value, 1.0)
	
	result = serializer.unserialize(-1)
	assert_no_error(result)
	assert_eq(result.value, -1.0)
	
	result = serializer.unserialize(1.0)
	assert_no_error(result)
	assert_eq(result.value, 1.0)

	result = serializer.unserialize("1")
	assert_no_error(result)
	assert_eq(result.value, 1.0)

	result = serializer.unserialize("1.0")
	assert_no_error(result)
	assert_eq(result.value, 1.0)

func test_min_max():
	var serializer: FloatSerializer = autofree(FloatSerializer.new())
	serializer.min = 1.0
	serializer.max = 3.0
	assert_error(serializer.unserialize(0.0), ERR_INVALID_DATA)
	assert_no_error(serializer.serialize(1.0))
	assert_no_error(serializer.serialize(3.0))
	assert_error(serializer.unserialize(4.0), ERR_INVALID_DATA)
