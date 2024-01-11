@tool
class_name StringSerializer extends Serializer

func get_type() -> Variant.Type:
	return TYPE_STRING

# Minimum value (inclusive)
var min = null:
	set(_min):
		if _min != null:
			assert(
				typeof(_min) == TYPE_INT,
				"The minimum value must be null or an integer, %s found."%Type.get_string_name(typeof(_min))
			)
		min = _min

# Maximum value (inclusive)
var max = null:
	set(_max):
		if _max != null:
			assert(
				typeof(_max) == TYPE_INT,
				"The maximum value must be null or an integer, %s found."%Type.get_string_name(typeof(_max))
			)
		max = _max

# Regular expression this string must match.
var pattern = null:
	set(_pattern):
		if _pattern != null:
			if _pattern is String:
				_pattern = RegEx.create_from_string(_pattern)
			assert(
				_pattern is RegEx,
				"The pattern must be a string or a compiled regular expression."
			)
		pattern = _pattern

func _init(_min = null, _max = null, _pattern = null):
	min = _min
	max = _max
	pattern = _pattern


func type_id() -> TypeID:
	return TypeID.STRING
	
func serialize(data) -> ErrorReturn:
	return _validate(data)

func unserialize(data) -> ErrorReturn:
	return _validate(data)

func _validate(data) -> ErrorReturn:
	if typeof(data) != TYPE_STRING:
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Expected string, got %s"%Type.get_string_name(typeof(data))
			)
		)
	if min != null and data.length() < min:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Invalid value, must be at least %d characters"%min)
		)
	if max != null and data.length() > max:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Invalid value, must be at most %d characters"%min)
		)
	if pattern != null and !pattern.search(data):
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Invalid value, must match %s"%pattern.get_pattern())
		)

	return ErrorReturn.new(
		data,
		null
	)

func to_jsonschema(defs: Dictionary) -> Dictionary:
	var result = {
		"type": "string"
	}
	if min != null:
		result["minLength"] = min
	if max != null:
		result["maxLength"] = max
	if pattern != null:
		result["pattern"] = pattern.get_pattern()
	return result
