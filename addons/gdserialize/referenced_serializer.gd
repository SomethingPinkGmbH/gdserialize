# The referenced serializer creates a reusable type in JSON schema.
class_name ReferencedSerializer extends PassthruSerializer

var name: String

func _init(_name: String, backing_serializer: Serializer):
	super._init(backing_serializer)
	name = _name

func to_jsonschema(defs: Dictionary) -> Dictionary:
	var schema = super.to_jsonschema(defs)
	if "$ref" in schema:
		return schema
	if !(name in defs):
		defs[name] = schema
	return {
		"$ref": "#/$defs/" + name
	}
