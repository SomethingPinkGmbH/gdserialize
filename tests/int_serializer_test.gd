extends SerializeTest


func test_int_serialization():
	var serializer: IntSerializer = autofree(IntSerializer.new())
	
	var result = serializer.serialize(0)
	assert_no_error(result)
	assert_eq(result.value, 0)
	
	result = serializer.serialize(1)
	assert_no_error(result)
	assert_eq(result.value, 1)
	
	result = autofree(serializer.serialize(-1))
	assert_no_error(result)
	assert_eq(result.value, -1)

func test_int_unserialization():
	var serializer: IntSerializer = autofree(IntSerializer.new())
	
	var result = serializer.unserialize(0)
	assert_no_error(result)
	assert_eq(result.value, 0)
	
	result = serializer.unserialize(1)
	assert_no_error(result)
	assert_eq(result.value, 1)
	
	result = serializer.unserialize(-1)
	assert_no_error(result)
	assert_eq(result.value, -1)
	
	result = serializer.unserialize(1.0)
	assert_no_error(result)
	assert_eq(result.value, 1)

	result = serializer.unserialize("1")
	assert_no_error(result)
	assert_eq(result.value, 1)

func test_min_max():
	var serializer: IntSerializer = autofree(IntSerializer.new())
	serializer.min = 1
	serializer.max = 3
	assert_error(serializer.unserialize(0), ERR_INVALID_DATA)
	assert_no_error(serializer.serialize(1))
	assert_no_error(serializer.serialize(3))
	assert_error(serializer.unserialize(4), ERR_INVALID_DATA)
