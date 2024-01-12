@tool
class_name OneOfSerializer extends Serializer

var discriminator_field: String
var discriminator_serializer: Serializer
var passthru_discriminator: bool
var discriminator_values: Dictionary

## Initialize the OneOfSerializer by specifying the discriminator field which distinguishes
## between the possible values.
func _init(
	new_discriminator_field: String,
	new_discriminator_serializer: Serializer,
	new_passthru_discriminator: bool,
	new_discriminator_values: Dictionary
):
	discriminator_field = new_discriminator_field
	discriminator_serializer = new_discriminator_serializer
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
	var valid_types: Array[String] = []
	for discriminator_value in discriminator_values:
		var backing_serializer: Serializer = discriminator_values[discriminator_value]
		valid_types.append(Class.get_string_name(backing_serializer.get_variant_type()))
		if is_instance_of(_data, backing_serializer.get_variant_type()):
			var serialization_result := backing_serializer.serialize(_data)
			if serialization_result.is_error():
				return serialization_result
			var serialized_discriminator := discriminator_serializer.serialize(discriminator_value)
			if serialized_discriminator.is_error():
				return ErrorReturn.new(
					null,
					Error.wrap(
						serialized_discriminator.error,
						serialized_discriminator.error.code,
						"The discriminator value for %s cannot be serialized by %s"%[
							Class.get_variable_class_or_type_name(serialization_result.value),
							Class.get_object_class_name(discriminator_serializer),
						]
					)
				)
			serialization_result.value[discriminator_field] = serialized_discriminator.value
			return serialization_result
	return ErrorReturn.new(
		null,
		Error.new(
			ERR_INVALID_DATA,
			"Incorrect type for one-of serialization: %s"%Class.get_variable_class_or_type_name(_data)
		)
	)

func unserialize(_data) -> ErrorReturn:
	if !(_data is Dictionary):
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Incorrect type for one-of serialization: %s (expected: dictionary)"%Class.get_variable_class_or_type_name(_data)
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
	var discriminator_value = _data[discriminator_field]
	var unserialized_discriminator = discriminator_serializer.unserialize(discriminator_value)
	if unserialized_discriminator.is_error():
		return ErrorReturn.new(
			null,
			Error.wrap(
				unserialized_discriminator.error,
				unserialized_discriminator.error.code,
				"Failed to unserialize discriminator field %s"%[discriminator_field]
			)
		)
	if !(unserialized_discriminator.value in discriminator_values):
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Invalid value for field %s: %s"%[discriminator_field, _data[discriminator_field]]
			)
		)
	var serializer: Serializer = discriminator_values[unserialized_discriminator.value]
	if !passthru_discriminator:
		_data.erase(discriminator_field)
	return serializer.unserialize(_data)

func to_jsonschema(defs: Dictionary) -> Dictionary:
	var one_of = []
	var discriminator_mappings = {}
	for discriminator_value in discriminator_values:
		var backing_serializer: Serializer = discriminator_values[discriminator_value]
		var backing_schema = backing_serializer.to_jsonschema(defs)
		discriminator_mappings[discriminator_value] = backing_schema["$ref"]
		var discriminator_schema = discriminator_serializer.to_jsonschema(defs)
		var serialized_discriminator_value = discriminator_serializer.serialize(discriminator_value)
		assert(
			serialized_discriminator_value.is_error() == false,
			str(serialized_discriminator_value.error)
		)
		discriminator_schema["enum"] = [serialized_discriminator_value.value]
		one_of.append({
			"allOf": [
				backing_schema,
			],
			"properties": {
				discriminator_field: discriminator_schema
			},
			"required": [discriminator_field],
			"additionalProperties": false
		})
	
	return {
		"oneOf": one_of
	}
