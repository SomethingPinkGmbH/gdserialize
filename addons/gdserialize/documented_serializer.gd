@tool
class_name DocumentedSerializer extends PassthruSerializer

var _title: String
var _description: String
var _examples: Array

func _init(title: String, description: String, backing_serializer: Serializer, examples: Array = []):
	super._init(backing_serializer)
	_title = title
	_description = description

func to_jsonschema(defs: Dictionary) -> Dictionary:
	var schema = _backing_serializer.to_jsonschema(defs)
	var converted_examples = []
	for example in _examples:
		var converted_example = serialize(example)
		assert(converted_example.error == null, "Cannot convert example value")
		converted_examples.append(converted_example.value)

	if "$ref" in schema:
		var defId = schema["$ref"].replace("#/$defs/","")
		var def = defs[defId]
		if !("title" in def) and !("description" in def):
			defs[defId]["title"] = _title
			defs[defId]["description"] = _description
			if converted_examples:
				defs[defId]["examples"] = converted_examples
			return schema

	schema["title"] = _title
	schema["description"] = _description
	if converted_examples:
		schema["examples"] = converted_examples
	return schema
