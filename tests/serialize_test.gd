class_name SerializeTest extends GutTest

func assert_no_error(ret: ErrorReturn) -> bool:
	assert_null(ret.error, "Unexpected error: %s"%ret.error)
	return ret.error == null

func assert_error(ret: ErrorReturn, code: int) -> bool:
	assert_not_null(ret.error, "No error returned")
	assert_eq(ret.error.code, code, "Invalid error code returned: %d"%ret.error.code)
	return ret.error and ret.error.code == code
