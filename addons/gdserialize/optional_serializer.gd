@tool
class_name OptionalSerializer extends PassthruSerializer

var _default_value

func _init(backing_serializer: Serializer, default_value = null):
	super._init(backing_serializer)
	_default_value = default_value

func serialize(data) -> ErrorReturn:
	if data == null:
		return ErrorReturn.new(_default_value, null)
	return _backing_serializer.serialize(data)

func unserialize(data) -> ErrorReturn:
	if data == null:
		if _default_value == null:
			return ErrorReturn.new(
				null,
				null
			)
		return _backing_serializer.unserialize(_default_value)
	return _backing_serializer.unserialize(data)

func is_equal(a, b) -> bool:
	if a == null and b == null:
		return true
	if a == null or b == null:
		return false
	return _backing_serializer.is_equal(a,b)

func is_optional() -> bool:
	return true

func to_jsonschema(defs: Dictionary) -> Dictionary:
	var schema = _backing_serializer.to_jsonschema(defs)
	schema["default"] = _default_value
	return schema
