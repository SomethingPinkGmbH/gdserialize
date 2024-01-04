class_name PassthruSerializer extends Serializer

var _backing_serializer: Serializer

func _init(backing_serializer: Serializer):
	_backing_serializer = backing_serializer

func is_equal(a, b) -> bool:
	return _backing_serializer.is_equal(a,b)

func is_optional() -> bool:
	return _backing_serializer.is_optional()

func type_id() -> TypeID:
	return _backing_serializer.type_id()
	
func get_type() -> Variant.Type:
	return _backing_serializer.get_type()

func serialize(_data) -> ErrorReturn:
	return _backing_serializer.serialize(_data)

func unserialize(_data) -> ErrorReturn:
	return _backing_serializer.unserialize(_data)

func to_jsonschema(defs: Dictionary) -> Dictionary:
	return _backing_serializer.to_jsonschema(defs)

func get_variant_type() -> Variant:
	return _backing_serializer.get_variant_type()
