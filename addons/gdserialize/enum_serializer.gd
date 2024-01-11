@tool
class_name EnumSerializer extends Serializer

enum Method {KEY,VALUE}

var values: Dictionary:
	set(_values):
		assert(typeof(_values) == TYPE_DICTIONARY)
		var i = 0
		for key in _values:
			var item = _values[key]
			assert(typeof(key) == TYPE_STRING)
			assert(typeof(item) == TYPE_INT)
			i+=1
		values = _values
var method: Method

func _init(_values: Dictionary, _method: Method = Method.KEY):
	values = _values
	method = _method

func type_id() -> TypeID:
	return TypeID.ENUM

func get_type() -> Variant.Type:
	# Funnily enough, Godot treates enums as dictionaries, mapping the names of enums as keys, the
	# int values as values.
	return TYPE_DICTIONARY

func serialize(data) -> ErrorReturn:
	if typeof(data) != TYPE_INT:
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Incorrect data type: %s, expected: int"%[Type.get_string_name(typeof(data))]
			)
		)
	if !(data in values.values()):
		var possible_values = PackedStringArray()
		for key in values:
			possible_values.append("%d"%[values[key]])
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Invalid value: %s (expected one of: %s)"%[
					data,",".join(possible_values)
				]
			)
		)
	match method:
		Method.KEY:
			for key in values:
				if values[key] == data: 
					return ErrorReturn.new(key, null)
			return ErrorReturn.new(
				null,
				Error.new(
					ERR_BUG,
					"Already validated data is invalid"
				)
			)
		Method.VALUE:
			return ErrorReturn.new(data, null)
	return ErrorReturn.new(
		null,
		Error.new(
			ERR_BUG,
			"Unhandled method: %d"%[method]
		)
	)

func unserialize(data) -> ErrorReturn:
	match method:
		Method.KEY:
			if typeof(data) != TYPE_STRING:
				return ErrorReturn.new(
					null,
					Error.new(
						ERR_INVALID_DATA,
						"Incorrect data type: %s, expected: string"%[Type.get_string_name(
							typeof(data)
						)]
					)
				)
			if !(data in values):
				return ErrorReturn.new(
					null,
					Error.new(
						ERR_INVALID_DATA,
						"Invalid value: %s (expected one of: %s)"%[data,",".join(values.keys())]
					)
				)
			return _validate(values[data])
		Method.VALUE:
			if typeof(data) != TYPE_INT and typeof(data) != TYPE_FLOAT:
				return ErrorReturn.new(
					null,
					Error.new(
						ERR_INVALID_DATA,
						"Incorrect data type: %s, expected: int"%[Type.get_string_name(typeof(data))]
					)
				)
			return _validate(int(data))
	return ErrorReturn.new(
		null,
		Error.new(ERR_BUG, "Incorrect serialization method: %d"%[method])
	)
	
func _validate(data: int) -> ErrorReturn:
	if !(data in values.values()):
		var possible_values = PackedStringArray()
		for key in values:
			possible_values.append("%d"%[values[key]])
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Invalid value: %s (expected one of: %s)"%[
					data,",".join(possible_values)
				]
			)
		)
	return ErrorReturn.new(data, null)

func to_jsonschema(defs: Dictionary) -> Dictionary:
	var result = {
	}
	match method:
		Method.KEY:
			result["type"] = "integer"
			result["enum"] = values.values()
		Method.VALUE:
			result["type"] = "string"
			result["enum"] = values.keys()
	return result
