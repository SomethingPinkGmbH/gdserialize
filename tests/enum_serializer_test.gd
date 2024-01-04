extends SerializeTest

enum TestEnum{Foo=1, Bar=2}

class TestObject:
	var foo

func test_serialize():
	var serializer = EnumSerializer.new(TestEnum, EnumSerializer.Method.KEY)
	
	assert_error(serializer.serialize({}), ERR_INVALID_DATA)
	assert_error(serializer.serialize([]), ERR_INVALID_DATA)
	assert_error(serializer.serialize(""), ERR_INVALID_DATA)
	assert_error(serializer.serialize(false), ERR_INVALID_DATA)
	assert_error(serializer.serialize(TestObject.new()), ERR_INVALID_DATA)
	assert_no_error(serializer.serialize(TestEnum.Foo))
	assert_no_error(serializer.serialize(TestEnum.Bar))
	assert_error(serializer.serialize(0), ERR_INVALID_DATA)
	assert_eq(serializer.serialize(TestEnum.Foo).get_value(), "Foo")
	assert_eq(serializer.serialize(TestEnum.Bar).get_value(), "Bar")
	
	serializer.method = EnumSerializer.Method.VALUE
	assert_eq(serializer.serialize(TestEnum.Foo).get_value(), 1)
	assert_eq(serializer.serialize(TestEnum.Bar).get_value(), 2)
