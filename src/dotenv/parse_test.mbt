///| Tests for the dotenv parse module
test "parse basic functionality" {
  let env_content = "GREETING=hello world\nNAME=MoonBit"
  let result = parse(env_content)
  inspect(result.size(), content="2")
  inspect(result.get("GREETING"), content="Some(\"hello world\")")
  inspect(result.get("NAME"), content="Some(\"MoonBit\")")
}

///|
test "parse handles empty lines and comments" {
  let env_content = "BASIC=basic\n\n# This is a comment\nAFTER_EMPTY=empty"
  let result = parse(env_content)
  inspect(result.size(), content="2")
  inspect(result.get("BASIC"), content="Some(\"basic\")")
  inspect(result.get("AFTER_EMPTY"), content="Some(\"empty\")")
  inspect(result.get("#COMMENT"), content="None")
}

///|
test "parse handles quoted values" {
  let env_content = "SINGLE='single quoted'\nDOUBLE=\"double quoted\""
  let result = parse(env_content)
  inspect(result.get("SINGLE"), content="Some(\"single quoted\")")
  inspect(result.get("DOUBLE"), content="Some(\"double quoted\")")
}

///|
test "parse handles empty values" {
  let env_content = "EMPTY_VALUE=\nEMPTY_SINGLE=''\nEMPTY_DOUBLE=\"\""
  let result = parse(env_content)
  inspect(result.get("EMPTY_VALUE"), content="Some(\"\")")
  inspect(result.get("EMPTY_SINGLE"), content="Some(\"\")")
  inspect(result.get("EMPTY_DOUBLE"), content="Some(\"\")")
}

///|
test "parse handles multiline values" {
  let env_content = "MULTILINE=\"hello\\nworld\""
  let result = parse(env_content)
  inspect(result.get("MULTILINE"), content="Some(\"hello\\nworld\")")
}

///|
test "parse handles whitespace" {
  let env_content = "VAR_WITH_SPACE = value\n  INDENTED_VAR=indented"
  let result = parse(env_content)
  inspect(result.get("VAR_WITH_SPACE"), content="Some(\"value\")")
  inspect(result.get("INDENTED_VAR"), content="Some(\"indented\")")
}

///|
test "parse handles export prefix" {
  let env_content = "export EXPORT_VAR=exported"
  let result = parse(env_content)
  inspect(result.get("EXPORT_VAR"), content="Some(\"exported\")")
}

///|
test "parse ignores invalid keys" {
  let env_content = "VALID_KEY=valid\n1INVALID=invalid"
  let result = parse(env_content)
  inspect(result.size(), content="1")
  inspect(result.get("VALID_KEY"), content="Some(\"valid\")")
  inspect(result.get("1INVALID"), content="None")
}

///|
test "parse handles special characters in values" {
  let env_content = "EQUALS=equ==als\nJSON='{\"foo\": \"bar\"}'"
  let result = parse(env_content)
  inspect(result.get("EQUALS"), content="Some(\"equ==als\")")
  inspect(result.get("JSON"), content="Some(\"{\\\"foo\\\": \\\"bar\\\"}\")")
}

///|
test "parse handles complex example" {
  let env_content = "# Comment\nBASIC=basic\n\nQUOTED='hello world'\nEMPTY="
  let result = parse(env_content)
  inspect(result.size(), content="3")
  inspect(result.get("BASIC"), content="Some(\"basic\")")
  inspect(result.get("QUOTED"), content="Some(\"hello world\")")
  inspect(result.get("EMPTY"), content="Some(\"\")")
}
