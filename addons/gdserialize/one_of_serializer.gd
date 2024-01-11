@tool
class_name OneOfSerializer extends Serializer

var discriminator_field: String
var passthru_discriminator: bool
var discriminator_values: Dictionary

# Initialize the OneOfSerializer by specifying the discriminator field.
func _init(
	new_discriminator_field: String,
	new_passthru_discriminator: bool,
	new_discriminator_values: Dictionary
):
	discriminator_field = new_discriminator_field
	passthru_discriminator = new_passthru_discriminator
	discriminator_values = new_discriminator_values

func is_equal(a, b) -> bool:
	for discriminator_value in discriminator_values:
		var backing_serializer: Serializer = discriminator_values[discriminator_value]
		if is_instance_of(a, backing_serializer.get_class_type()):
			if is_instance_of(b, backing_serializer.get_class_type()):
				return backing_serializer.is_equal(a, b)
			else:
				return false
	return false

func is_optional() -> bool:
	return false

func type_id() -> TypeID:
	return TypeID.OBJECT
	
func get_type() -> Variant.Type:
	return TYPE_OBJECT

func serialize(_data) -> ErrorReturn:
	for discriminator_value in discriminator_values:
		var backing_serializer: Serializer = discriminator_values[discriminator_value]
		if is_instance_of(_data, backing_serializer.get_variant_type()):
			var serialization_result = backing_serializer.serialize(_data)
			if serialization_result.is_error():
				return serialization_result
			serialization_result.value[discriminator_field] = discriminator_value
			return serialization_result
	return ErrorReturn.new(
		null,
		Error.new(
			ERR_INVALID_DATA,
			"Incorrect type for one-of serialization: %s"%Type.get_string_name(typeof(_data))
		)
	)

func unserialize(_data) -> ErrorReturn:
	if !(_data is Dictionary):
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Incorrect type for one-of serialization: %s"%Type.get_string_name(typeof(_data))
			)
		)
	if !(discriminator_field in _data):
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Missing object discriminator field: %s"%discriminator_field
			)
		)
	if !(_data[discriminator_field] in discriminator_values):
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Invalid value for field %s: %s"%[discriminator_field, _data[discriminator_field]]
			)
		)
	var serializer: Serializer = discriminator_values[_data[discriminator_field]]
	if !passthru_discriminator:
		_data.erase(discriminator_field)
	return serializer.unserialize(_data)

func to_jsonschema(defs: Dictionary) -> Dictionary:
	var oneOf = []
	var discriminatorMappings = {}
	for discriminator_value in discriminator_values:
		var backing_serializer: Serializer = discriminator_values[discriminator_value]
		var backing_schema = backing_serializer.to_jsonschema(defs)
		discriminatorMappings[discriminator_value] = backing_schema["$ref"]
		oneOf.append({
			"allOf": [
				backing_schema,
			],
			"properties": {
				discriminator_field: {"type": "string", "enum": [discriminator_value]}
			},
			"required": [discriminator_field],
			"additionalProperties": false
		})
	
	return {
		"oneOf": oneOf
	}
