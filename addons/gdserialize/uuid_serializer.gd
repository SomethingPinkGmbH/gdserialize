class_name UUIDSerializer extends StringSerializer

func _init():
	super._init(
		36,
		36,
		"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
	)


func type_id() -> TypeID:
	return TypeID.UUID

func to_jsonschema(defs: Dictionary) -> Dictionary:
	var data = super.to_jsonschema(defs)
	data["format"] = "uuid"
	return data
