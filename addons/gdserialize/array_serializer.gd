class_name ArraySerializer
extends Serializer

var items: Serializer
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

func _init(_items: Serializer, _min = null, _max = null):
	items = _items
	min = _min
	max = _max

func type_id() -> TypeID:
	return TypeID.ARRAY

func is_equal(a, b) -> bool:
	if a.size() != b.size():
		return false
	var i = 0
	for a_item in a:
		if !items.is_equal(a_item, b[i]):
			return false
		i += 1
	return true

func get_type() -> Variant.Type:
	return TYPE_ARRAY

func serialize(data) -> ErrorReturn:
	if typeof(data) != TYPE_ARRAY:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Incorrect data type: %s, expected: array"%Type.get_string_name(typeof(data)))
		)
	var result = []
	
	var i = 0
	for item in data:
		var serialized_item = items.serialize(item)
		if !serialized_item.is_ok():
			return ErrorReturn.new(null, Error.new(
				serialized_item.error.code,
				"Failed to serialize item %d: %s"%[i,serialized_item.error]
			))
		result.append(serialized_item.value)
		i += 1
	return _validate(result)

func unserialize(data) -> ErrorReturn:
	if typeof(data) != TYPE_ARRAY:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Incorrect data type: %s, expected: array"%Type.get_string_name(typeof(data)))
		)
	var result = []
	var i = 0
	for item in data:
		var unserialized_item = items.unserialize(item)
		if !unserialized_item.is_ok():
			return ErrorReturn.new(null, Error.new(
				unserialized_item.error.code,
				"Failed to unserialize item %d: %s"%[i,unserialized_item.error]
			))
		result.append(unserialized_item.value)
		i += 1
	return _validate(result)

func _validate(value: Array) -> ErrorReturn:
	if min != null and value.size() < min:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Invalid value, must contain at least %d items"%min)
		)
	if max != null and value.size() > max:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Invalid value, must contain at most %d items"%max)
		)
	return ErrorReturn.new(value, null)

func to_jsonschema(defs: Dictionary) -> Dictionary:
	var result = {
		"type": "array",
		"items": items.to_jsonschema(defs)
	}
	if min != null:
		result["minItems"] = min
	if max != null:
		result["maxItems"] = max
	return result
