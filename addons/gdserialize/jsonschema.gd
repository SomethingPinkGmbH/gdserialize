@tool
class_name JSONSchema extends Object

static func from_serializer(serializer: Serializer, id: String) -> Dictionary:
	var defs = {}
	var schema = serializer.to_jsonschema(defs)
	if "$ref" in schema:
		var root_object = schema["$ref"].replace("#/$defs/", "")
		schema = defs[root_object].duplicate(true)
		defs[root_object] = {"$ref":"#"}
	schema["$defs"] = defs
	schema["$schema"] = "https://json-schema.org/draft/2020-12/schema"
	schema["$id"] = id
	return schema
