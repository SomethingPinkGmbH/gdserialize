@tool
class_name DictionarySerializer extends Serializer

var keys: Serializer
var values: Serializer

# Minimum number of items (inclusive)
var min = null:
	set(_min):
		if _min != null:
			assert(
				typeof(_min) == TYPE_INT,
				"The minimum number of items must be null or an integer, %s found."%[Type.get_string_name(typeof(_min))]
			)
		min = _min

# Maximum number of items (inclusive)
var max = null:
	set(_max):
		if _max != null:
			assert(
				typeof(_max) == TYPE_INT,
				"The maximum number of items must be null or an integer, %s found."%[Type.get_string_name(typeof(_max))]
			)
		max = _max

func _init(_keys: Serializer, _values: Serializer, _min = null, _max = null):
	keys = _keys
	values = _values
	min = _min
	max = _max

func is_equal(a, b) -> bool:
	if a.size() != b.size():
		return false
	for a_key in a:
		if !(a_key in b):
			return false
		if !values.is_equal(a[a_key], b[a_key]):
			return false
	return true

func type_id() -> TypeID:
	return TypeID.DICTIONARY
	
func get_type() -> Variant.Type:
	return TYPE_DICTIONARY
	
func serialize(data) -> ErrorReturn:
	if typeof(data) != TYPE_DICTIONARY:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Incorrect data type: %s, expected: dictionary"%[Type.get_string_name(typeof(data))])
		)
	var result = {}
	for key in data:
		var serialized_key_result = keys.serialize(key)
		if !serialized_key_result.is_ok():
			return ErrorReturn.new(
				null,
				Error.wrap(serialized_key_result.error, ERR_INVALID_DATA, "Failed to serialize dict key")
			)
		var serialized_value_result = values.serialize(data[key])
		if !serialized_value_result.is_ok():
			return ErrorReturn.new(
				null,
				Error.wrap(serialized_value_result.error, ERR_INVALID_DATA, "Failed to serialize dict value")
			)
		result[serialized_key_result.get_value()] = serialized_value_result.get_value()
	return _validate(result)

func unserialize(data) -> ErrorReturn:
	if typeof(data) != TYPE_DICTIONARY:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Incorrect data type: %s, expected: dictionary"%[Type.get_string_name(typeof(data))])
		)
	var result = {}
	
	for key in data:
		var unserialized_key_result = keys.unserialize(key)
		if !unserialized_key_result.is_ok():
			return ErrorReturn.new(
				null,
				Error.wrap(unserialized_key_result.error, ERR_INVALID_DATA, "Failed to unserialize dict key")
			)
		var unserialized_value_result = values.unserialize(data[key])
		if !unserialized_value_result.is_ok():
			return ErrorReturn.new(
				null,
				Error.wrap(unserialized_value_result.error, ERR_INVALID_DATA, "Failed to unserialize dict value")
			)
		result[unserialized_key_result.get_value()] = unserialized_value_result.get_value()
	
	return _validate(result)
		
func _validate(value: Dictionary) -> ErrorReturn:
	if min != null and value.size() < min:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Invalid value, must contain at least %d items"%[min])
		)
	if max != null and value.size() > max:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Invalid value, must contain at most %d items"%[max])
		)
	return ErrorReturn.new(value, null)
	
func to_jsonschema(defs: Dictionary) -> Dictionary:
	var result = {
		"type": "object",
		"additionalProperties": {
			"type": values.to_jsonschema(defs)
		},
	}
	
	var key_type = keys.to_jsonschema(defs)
	match key_type["type"]:
		"number":
			result["propertyNames"] = {
				"pattern": "^(-|)[0-9]+$"
			}
	if min != null:
		result["minItems"] = min
	if max != null:
		result["maxItems"] = max
	return result
