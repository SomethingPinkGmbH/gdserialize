class_name BoolSerializer extends Serializer

func type_id() -> TypeID:
	return TypeID.BOOL

func serialize(data) -> ErrorReturn:
	return _validate(data)

func unserialize(data) -> ErrorReturn:
	return _validate(data)
	
func get_type() -> Variant.Type:
	return TYPE_BOOL

func _validate(data) -> ErrorReturn:
	if typeof(data) != TYPE_BOOL:
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Expected bool, got %s"%[Type.get_string_name(typeof(data))]
			)
		)

	return ErrorReturn.new(
		data,
		null
	)

func to_jsonschema(defs: Dictionary) -> Dictionary:
	return {
		"type": "boolean"
	}
