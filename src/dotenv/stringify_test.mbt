///|
/// Tests for the dotenv stringify module
test "stringify basic functionality" {
  let env : Map[String, String] = Map::new()
  env["GREETING"] = "hello world"
  env["NAME"] = "MoonBit"
  let result = stringify(env)

  // Check that both key-value pairs are present in the result
  // GREETING has a space so gets quoted, NAME doesn't need quotes
  let has_greeting = result.contains("GREETING='hello world'")
  let has_name = result.contains("NAME=MoonBit")
  inspect(has_greeting && has_name, content="true")
}

///|
test "stringify handles simple values" {
  let env : Map[String, String] = Map::new()
  env["SIMPLE"] = "value"
  let result = stringify(env)
  inspect(result, content="SIMPLE=value")
}

///|
test "stringify handles empty values" {
  let env : Map[String, String] = Map::new()
  env["EMPTY"] = ""
  let result = stringify(env)
  inspect(result, content="EMPTY=")
}

///|
test "stringify handles special characters" {
  let env : Map[String, String] = Map::new()
  env["SPECIAL"] = "hello world!"
  let result = stringify(env)
  inspect(result, content="SPECIAL='hello world!'")
}

///|
test "stringify handles values with quotes" {
  let env : Map[String, String] = Map::new()
  env["WITH_SINGLE"] = "value with 'quote'"
  env["WITH_DOUBLE"] = "value with \"quote\""
  let result = stringify(env)

  // Values with single quotes should use double quotes
  inspect(result.contains("WITH_SINGLE=\"value with 'quote'\""), content="true")
  // Values with double quotes should use double quotes with escaping
  inspect(result.contains("WITH_DOUBLE="), content="true")
}

///|
test "stringify handles multiline values" {
  let env : Map[String, String] = Map::new()
  env["MULTILINE"] = "line1\nline2"
  let result = stringify(env)

  // Multiline values should use double quotes with escaped newlines
  inspect(result, content="MULTILINE=\"line1\\\\nline2\"")
}

///|
test "stringify handles numeric-like values" {
  let env : Map[String, String] = Map::new()
  env["NUMBER"] = "123"
  env["FLOAT"] = "3.14"
  let result = stringify(env)

  // NUMBER stays unquoted, FLOAT gets quoted due to the period
  let has_number = result.contains("NUMBER=123")
  let has_float = result.contains("FLOAT='3.14'")
  inspect(has_number && has_float, content="true")
}

///|
test "stringify ignores comment keys" {
  let env : Map[String, String] = Map::new()
  env["VALID"] = "value"
  env["#COMMENT"] = "comment"
  let result = stringify(env)
  inspect(result.contains("VALID=value"), content="true")
  inspect(result.contains("#COMMENT"), content="false")
}

///|
test "stringify handles complex example" {
  let env : Map[String, String] = Map::new()
  env["BASIC"] = "basic"
  env["QUOTED"] = "hello world"
  env["EMPTY"] = ""
  env["NUMBER"] = "42"
  let result = stringify(env)
  inspect(result.contains("BASIC=basic"), content="true")
  inspect(result.contains("QUOTED='hello world'"), content="true")
  inspect(result.contains("EMPTY="), content="true")
  inspect(result.contains("NUMBER=42"), content="true")
}

///|
test "stringify handles equals in values" {
  let env : Map[String, String] = Map::new()
  env["EQUALS"] = "equ==als"
  let result = stringify(env)
  inspect(result, content="EQUALS='equ==als'")
}

///|
test "stringify handles single-quote characters in values" {
  let env : Map[String, String] = Map::new()
  env["PARSE"] = "par'se"
  let result = stringify(env)
  // Values with single quotes should use double quotes
  inspect(result, content="PARSE=\"par'se\"")
}

///|
test "stringify preserves whitespace in values" {
  let env : Map[String, String] = Map::new()
  env["WHITESPACE"] = "    whitespace   "
  let result = stringify(env)
  inspect(result, content="WHITESPACE='    whitespace   '")
}
