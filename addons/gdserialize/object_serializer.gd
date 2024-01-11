@tool
class_name ObjectSerializer extends Serializer

func is_equal(a, b) -> bool:
	for field_name in _serializable_fields:
		var field = _serializable_fields[field_name]
		if !field.is_equal(a.get(field_name), b.get(field_name)):
			return false
	return true

func get_type() -> Variant.Type:
	return TYPE_OBJECT

# Name of the class. This is needed because Godot can't provide this information.
var _name: String

# The target class is the class that should be instantiated when unserialize is called.
var _target_class

# This variable contains a description of all serializable fields in this object.
# The keys must be the field names and must match the variable names in the object.
# The values must be SerializableTypes.
var _serializable_fields: Dictionary = {}

func _init(name: String, target_class, serializable_fields: Dictionary):
	assert(name != "", "The class name cannot be empty.")
	var test_instance: Object = target_class.new()
	var target_class_fields = test_instance.get_property_list()
	var field_names = []
	for field in target_class_fields:
		field_names.append(field["name"])
	for field in serializable_fields:
		assert(
			field in field_names,
			"Field %s on object %s is declared as serializable, but is not found in the object."%[field,name]
		)
	_name = name
	_serializable_fields = serializable_fields
	_target_class = target_class

func type_id() -> TypeID:
	return TypeID.OBJECT
	
func get_variant_type() -> Variant:
	return _target_class

func serialize(data) -> ErrorReturn:
	if typeof(data) != TYPE_OBJECT:
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Incorrect type for object serialization: %s"%Type.get_string_name(typeof(data))
			)
		)
	var result = {}
	for field_name in _serializable_fields:
		var field = _serializable_fields[field_name]
		var value = data.get(field_name)
		var field_result = field.serialize(value)
		if field_result.error:
			return ErrorReturn.new(
				null,
				Error.wrap(
					field_result.error,
					-1,
					"Failed to serialize field %s: %s"%[field_name, field_result.error.message]
				)
			)
		result[field_name] = field_result.value
	return ErrorReturn.new(result, null)

func unserialize(data) -> ErrorReturn:
	if typeof(data) != TYPE_DICTIONARY:
		return ErrorReturn.new(null, Error.new(
			ERR_INVALID_DATA,
			"Expected dictionary, found %s"%Type.get_type_name(data)
		))
	
	var result: Object = _target_class.new()
	for field_name in _serializable_fields:
		var field = _serializable_fields[field_name]
		var value = data.get(field_name)
		var field_result = field.unserialize(value)
		if field_result.error:
			return ErrorReturn.new(
				null,
				Error.new(
					field_result.error.code,
					"Failed to unserialize field %s: %s"%[field_name, field_result.error.message]
				)
			)
		var set_value = field_result.value
		result.set(field_name, set_value)
	return ErrorReturn.new(result, null)

func to_jsonschema(defs: Dictionary) -> Dictionary:
	if _name in defs:
		return {
			"$ref": "#/$defs/" + _name
		}
	defs[_name] = {
		"type": "object",
		"additionalProperties": false,
		"properties": {},
		"required": []
	}
	for field_name in _serializable_fields:
		defs[_name]["properties"][field_name] = _serializable_fields[field_name].to_jsonschema(defs)
		if !_serializable_fields[field_name].is_optional():
			defs[_name]["required"].append(field_name)
	
	return {
		"$ref": "#/$defs/" + _name
	}
