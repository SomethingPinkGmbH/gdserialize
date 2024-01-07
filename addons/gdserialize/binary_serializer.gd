class_name BinarySerializer extends Serializer

var contentEncoder: ContentEncoder = Base64ContentEncoder.new()

func _init(_contentEncoder: ContentEncoder = Base64ContentEncoder.new()):
	contentEncoder = _contentEncoder

func type_id() -> TypeID:
	return TypeID.BYTES

func serialize(data) -> ErrorReturn:
	if typeof(data) != TYPE_PACKED_BYTE_ARRAY:
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Expected packed byte array, got %s"%[Type.get_string_name(typeof(data))]
			)
		)
	return ErrorReturn.new(Marshalls.raw_to_base64(data), null)

func unserialize(data) -> ErrorReturn:
	if typeof(data) != TYPE_STRING:
		return ErrorReturn.new(
			null,
			Error.new(
				ERR_INVALID_DATA,
				"Expected string, got %s"%[Type.get_string_name(typeof(data))]
			)
		)
	return ErrorReturn.new(Marshalls.base64_to_raw(data), null)

func get_type() -> Variant.Type:
	return TYPE_BOOL

func to_jsonschema(defs: Dictionary) -> Dictionary:
	return {
		"type": "string",
		"contentEncoding": contentEncoder.json_schema()
	}

class ContentEncoder:
	func encode(data: PackedByteArray) -> String:
		return ""
	func decode(data: String) -> PackedByteArray:
		return PackedByteArray()
	func json_schema() -> String:
		return ""

class Base64ContentEncoder extends ContentEncoder:
	func encode(data: PackedByteArray) -> String:
		return Marshalls.raw_to_base64(data)
		
	func decode(data: String) -> PackedByteArray:
		return Marshalls.base64_to_raw(data)
		
	func json_schema() -> String:
		return "base64"
