class_name IntSerializer extends Serializer

func get_type() -> Variant.Type:
	return TYPE_INT

static var int_re = RegEx.new()

static func _static_init():
	int_re.compile("^[0-9]+$")

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

func _init(_min = null, _max = null):
	min = _min
	max = _max

func type_id() -> TypeID:
	return TypeID.INT

func serialize(data) -> ErrorReturn:
	if typeof(data) != TYPE_INT:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Incorrect data type: %s, expected: int"%Type.get_string_name(typeof(data)))
		)
	return _validate(data)

func unserialize(data) -> ErrorReturn:
	match typeof(data):
		TYPE_INT:
			return _validate(data)
		TYPE_FLOAT:
			return _validate(int(data))
		TYPE_STRING:
			data = data.strip_edges()
			if int_re.search(data):
				return _validate(int(data))
	return ErrorReturn.new(
		null,
		Error.new(
			ERR_INVALID_DATA,
			"Incorrect data type: %s, expected: int, float, or string containing an integer"%Type.get_string_name(typeof(data))
		)
	)

func _validate(value: int) -> ErrorReturn:
	if min != null and value < min:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Invalid value, must be at least %d"%min)
		)
	if max != null and value > max:
		return ErrorReturn.new(
			null,
			Error.new(ERR_INVALID_DATA, "Invalid value, must be at most %d"%max)
		)
	return ErrorReturn.new(value, null)

func to_jsonschema(defs: Dictionary) -> Dictionary:
	var result = {
		"type": "integer"
	}
	if min != null:
		result["minimum"] = min
	if max != null:
		result["maximum"] = max
	return result
