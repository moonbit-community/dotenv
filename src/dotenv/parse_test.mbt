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

///| Test variable expansion functionality
test "parse expands variables" {
  let env_content = "THE_ANSWER=42\nEXPAND_VAR=$THE_ANSWER"
  let result = parse(env_content)
  inspect(result.get("THE_ANSWER"), content="Some(\"42\")")
  inspect(result.get("EXPAND_VAR"), content="Some(\"42\")")
}

///|
test "parse expands variables with brackets" {
  let env_content = "THE_ANSWER=42\nEXPAND_VAR=${THE_ANSWER}"
  let result = parse(env_content)
  inspect(result.get("EXPAND_VAR"), content="Some(\"42\")")
}

///|
test "parse expands multiple variables" {
  let env_content = "QUOTED_SINGLE='single quoted'\nQUOTED_DOUBLE=\"double quoted\"\nEXPAND_TWO_VARS=$QUOTED_SINGLE!==$QUOTED_DOUBLE"
  let result = parse(env_content)
  inspect(
    result.get("EXPAND_TWO_VARS"),
    content="Some(\"single quoted!==double quoted\")",
  )
}

///|
test "parse expands recursive variables" {
  let env_content = "QUOTED_SINGLE='single quoted'\nQUOTED_DOUBLE=\"double quoted\"\nEXPAND_TWO_VARS=$QUOTED_SINGLE!==$QUOTED_DOUBLE\nEXPAND_RECURSIVE=$EXPAND_TWO_VARS"
  let result = parse(env_content)
  inspect(
    result.get("EXPAND_RECURSIVE"),
    content="Some(\"single quoted!==double quoted\")",
  )
}

///|
test "parse handles default values" {
  let env_content = "THE_ANSWER=42\nEXPAND_DEFAULT_TRUE=${NO_SUCH_VAR:-default}\nEXPAND_DEFAULT_FALSE=${THE_ANSWER:-default}"
  let result = parse(env_content)
  inspect(result.get("EXPAND_DEFAULT_TRUE"), content="Some(\"default\")")
  inspect(result.get("EXPAND_DEFAULT_FALSE"), content="Some(\"42\")")
}

///|
test "parse handles nested default values" {
  let env_content = "THE_ANSWER=42\nEXPAND_DEFAULT_VAR=${NO_SUCH_VAR:-${THE_ANSWER:-default}}"
  let result = parse(env_content)
  inspect(result.get("EXPAND_DEFAULT_VAR"), content="Some(\"42\")")
}

///|
test "parse handles escaped variables" {
  let env_content = "THE_ANSWER=42\nEXPAND_ESCAPED=\\$THE_ANSWER"
  let result = parse(env_content)
  inspect(result.get("EXPAND_ESCAPED"), content="Some(\"$THE_ANSWER\")")
}

///|
test "parse handles mixed expansion styles" {
  let env_content = "QUOTED_SINGLE='single quoted'\nQUOTED_DOUBLE=\"double quoted\"\nEXPAND_WITH_DIFFERENT_STYLES=${QUOTED_SINGLE}!==$QUOTED_DOUBLE"
  let result = parse(env_content)
  inspect(
    result.get("EXPAND_WITH_DIFFERENT_STYLES"),
    content="Some(\"single quoted!==double quoted\")",
  )
}

///|
test "parse doesn't expand variables in single quotes" {
  let env_content = "THE_ANSWER=42\nSINGLE_QUOTED='$THE_ANSWER'"
  let result = parse(env_content)
  inspect(result.get("SINGLE_QUOTED"), content="Some(\"$THE_ANSWER\")")
}

///|
test "parse expands variables in double quotes" {
  let env_content = "THE_ANSWER=42\nDOUBLE_QUOTED=\"Value is $THE_ANSWER\""
  let result = parse(env_content)
  inspect(result.get("DOUBLE_QUOTED"), content="Some(\"Value is $THE_ANSWER\")")
}

///|
test "parse handles default with special characters" {
  let env_content = "EXPAND_DEFAULT_WITH_SPECIAL_CHARACTERS=${UNDEFINED_ENV_KEY:-/default/path}"
  let result = parse(env_content)
  inspect(
    result.get("EXPAND_DEFAULT_WITH_SPECIAL_CHARACTERS"),
    content="Some(\"/default/path\")",
  )
}
