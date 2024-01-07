extends GutTest

func test_base64():
	var binaryData = PackedByteArray([0, 27, 'a'])
	var encoder = BinarySerializer.new()
	var result = encoder.serialize(binaryData)
	assert_true(result.is_ok())
	
	var decodedData = Marshalls.base64_to_raw(result.value)
	assert_eq(decodedData, binaryData)
	decodedData = PackedByteArray()
	
	result = encoder.unserialize(result.value)
	assert_true(result.is_ok())
	assert_eq(result.value, binaryData)
