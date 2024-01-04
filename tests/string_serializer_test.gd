extends SerializeTest

func test_string_serialization():
	var serializer: StringSerializer = autofree(StringSerializer.new())
	
	var result = serializer.serialize("")
	assert_no_error(result)
	assert_eq(result.value, "")
	
	result = serializer.serialize("Hello world!")
	assert_true(result.is_ok())
	assert_eq(result.value, "Hello world!")
	
func test_string_unserialization():
	var serializer: StringSerializer = autofree(StringSerializer.new())
	
	var result = serializer.unserialize("")
	assert_no_error(result)
	assert_eq(result.value, "")
	
	result = serializer.unserialize("Hello world!")
	assert_no_error(result)
	assert_eq(result.value, "Hello world!")

func test_min_max():
	var serializer: StringSerializer = autofree(StringSerializer.new(1, 3))
	assert_error(serializer.unserialize(""), ERR_INVALID_DATA)
	assert_no_error(serializer.serialize("a"))
	assert_no_error(serializer.serialize("abc"))
	assert_error(serializer.unserialize("4.0abcd"), ERR_INVALID_DATA)

func test_regexp():
	var serializer: StringSerializer = autofree(StringSerializer.new(null, null, "^[a-z]$"))
	assert_error(serializer.unserialize(""), ERR_INVALID_DATA)
	assert_no_error(serializer.serialize("a"))
	assert_error(serializer.unserialize("ab"), ERR_INVALID_DATA)
	assert_error(serializer.unserialize("4.0abcd"), ERR_INVALID_DATA)
