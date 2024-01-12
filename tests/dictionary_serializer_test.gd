extends SerializeTest

class TestData:
	var a: int

func test_array_serialization():
	var serializer: DictionarySerializer = DictionarySerializer.new(
		IntSerializer.new(),
		ObjectSerializer.new(
			"TestData",
			TestData,
			{
				"a": IntSerializer.new()
			}
		)
	)
	
	assert_error(serializer.serialize([]), ERR_INVALID_DATA)
	assert_error(serializer.serialize(1), ERR_INVALID_DATA)
	assert_error(serializer.serialize(1.0), ERR_INVALID_DATA)
	assert_error(serializer.serialize(TestData.new()), ERR_INVALID_DATA)
	
	var test_dict: Dictionary = {42: TestData.new()}
	test_dict[42].a = 42
	var serialized_dict = serializer.serialize(test_dict)
	assert_no_error(serialized_dict)
	assert_eq(serialized_dict.value.size(), 1)
	assert_true(serialized_dict.value is Dictionary)
	assert_true(serialized_dict.value[42] is Dictionary)
	assert_eq(serialized_dict.value[42]["a"], 42)

func test_array_unserialization():
	var serializer: DictionarySerializer = DictionarySerializer.new(
		IntSerializer.new(),
		ObjectSerializer.new(
			"TestData",
			TestData,
			{
				"a": IntSerializer.new()
			}
		)
	)
	
	assert_error(serializer.unserialize([]), ERR_INVALID_DATA)
	assert_error(serializer.unserialize(1), ERR_INVALID_DATA)
	assert_error(serializer.unserialize(1.0), ERR_INVALID_DATA)
	assert_error(serializer.unserialize(TestData.new()), ERR_INVALID_DATA)

	var test_dict: Dictionary = {42:{"a":42}}
	var unserialized_dict = serializer.unserialize(test_dict)
	assert_no_error(unserialized_dict)
	assert_eq(unserialized_dict.value.size(), 1)
	assert_true(unserialized_dict.value is Dictionary)
	assert_true(unserialized_dict.value[42] is TestData)
	assert_eq(unserialized_dict.value[42].a, 42)

func test_min_max():
	var serializer: DictionarySerializer = DictionarySerializer.new(
		IntSerializer.new(),
		ObjectSerializer.new(
			"TestData",
			TestData,
			{
				"a": IntSerializer.new()
			}
		),
		1,
		3
	)
	assert_error(serializer.unserialize({}), ERR_INVALID_DATA)
	assert_no_error(serializer.serialize({1:TestData.new()}))
	assert_no_error(serializer.serialize({1:TestData.new(),2:TestData.new(),3:TestData.new()}))
	assert_error(serializer.unserialize({1:{},2:{},3:{},4:{}}), ERR_INVALID_DATA)
	
