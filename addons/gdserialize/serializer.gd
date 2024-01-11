@tool
class_name Serializer extends RefCounted

enum TypeID{
	UNKNOWN,
	ARRAY,
	BOOL,
	DICTIONARY,
	ENUM,
	FLOAT,
	INT,
	OBJECT,
	STRING,
	UUID,
	BYTES,
}

func type_id() -> TypeID:
	return TypeID.UNKNOWN

func is_equal(a, b) -> bool:
	return a == b

# Indicate that this serializer is optional.
func is_optional() -> bool:
	return false

# This function returns the unserialized type supported by this serializer.
func get_type() -> Variant.Type:
	assert(false, "get_type is not implemented")
	return TYPE_NIL

func get_variant_type() -> Variant:
	return get_type()

# Serialize serializes the current object into a wire-capable form. If an error happens, the second
# parameter of the ErrorReturn contains the error.
func serialize(_data) -> ErrorReturn:
	return ErrorReturn.new(null, Error.not_implemented())

# Unserialize unserializes the value into the current object. It returns an error if the
# unserialization could not be completed.
func unserialize(_data) -> ErrorReturn:
	return ErrorReturn.new(null, Error.not_implemented())

# Output the corresponding JSON schema fragment for this type. The defs dictionary holds the
# referencable types.
func to_jsonschema(defs: Dictionary) -> Dictionary:
	assert(false, "Not implemented")
	return {}
