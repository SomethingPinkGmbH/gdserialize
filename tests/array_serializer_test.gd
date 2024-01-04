extends SerializeTest

class TestData:
	var a: int

func test_array_serialization():
	var serializer: ArraySerializer = ArraySerializer.new(
		ObjectSerializer.new(
			"TestData",
			TestData,
			{
				"a": IntSerializer.new()
			}
		)
	)
	
	assert_error(serializer.serialize(null), ERR_INVALID_DATA)
	assert_error(serializer.serialize({}), ERR_INVALID_DATA)
	assert_error(serializer.serialize(1), ERR_INVALID_DATA)
	assert_error(serializer.serialize(1.0), ERR_INVALID_DATA)
	assert_error(serializer.serialize(TestData.new()), ERR_INVALID_DATA)
	
	var test_list: Array[TestData] = [TestData.new()]
	test_list[0].a = 42
	var serialized_array = serializer.serialize(test_list)
	assert_no_error(serialized_array)
	assert_eq(serialized_array.value.size(), 1)
	assert_true(serialized_array.value[0] is Dictionary)
	assert_eq(serialized_array.value[0]["a"], 42)

func test_array_unserialization():
	var serializer: ArraySerializer = autofree(
		ArraySerializer.new(
			ObjectSerializer.new(
				"TestData",
				TestData,
				{
					"a": IntSerializer.new()
				}
			)
		)
	)
	
	assert_error(serializer.unserialize(null), ERR_INVALID_DATA)
	assert_error(serializer.unserialize({}), ERR_INVALID_DATA)
	assert_error(serializer.unserialize(1), ERR_INVALID_DATA)
	assert_error(serializer.unserialize(1.0), ERR_INVALID_DATA)
	assert_error(serializer.unserialize(TestData.new()), ERR_INVALID_DATA)

	var test_list: Array = [{"a":42}]
	var serialized_array = serializer.unserialize(test_list)
	assert_no_error(serialized_array)
	assert_eq(serialized_array.value.size(), 1)
	assert_true(serialized_array.value[0] is TestData)
	assert_eq(serialized_array.value[0].a, 42)

func test_min_max():
	var serializer: ArraySerializer = autofree(
		ArraySerializer.new(
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
	)
	assert_error(serializer.unserialize([]), ERR_INVALID_DATA)
	assert_no_error(serializer.serialize([TestData.new()]))
	assert_no_error(serializer.serialize([TestData.new(),TestData.new(),TestData.new()]))
	assert_error(serializer.unserialize([TestData.new(),TestData.new(),TestData.new(),TestData.new()]), ERR_INVALID_DATA)
	
