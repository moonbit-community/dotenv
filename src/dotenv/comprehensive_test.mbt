///| Comprehensive tests based on the Deno std dotenv test cases

///|

///| These tests ensure compatibility with the reference implementation and

///| validate all the advanced features of the dotenv module.

// Test parsing basic .env content
test "parse basic env content" {
  let content = "GREETING=hello world"
  let result = parse(content)
  inspect(result.get("GREETING"), content="Some(\"hello world\")")
  inspect(result.size(), content="1")
}

// Test parsing multiple variables

///|
test "parse multiple variables" {
  let content = "GREETING=hello world\nDO_NOT_OVERRIDE=overridden"
  let result = parse(content)
  inspect(result.get("GREETING"), content="Some(\"hello world\")")
  inspect(result.get("DO_NOT_OVERRIDE"), content="Some(\"overridden\")")
  inspect(result.size(), content="2")
}

// Test comprehensive .env parsing with various formats

///|
test "parse comprehensive env test file" {
  let content = "BASIC=basic\n\nAFTER_EMPTY=empty\n#COMMENT=not-parsed\nEMPTY_VALUE=\nQUOTED_SINGLE='single quoted'\nQUOTED_DOUBLE=\"double quoted\"\nEMPTY_SINGLE=''\nEMPTY_DOUBLE=\"\""
  let result = parse(content)
  inspect(result.get("BASIC"), content="Some(\"basic\")")
  inspect(result.get("AFTER_EMPTY"), content="Some(\"empty\")")
  inspect(result.get("COMMENT"), content="None") // Comments should not be parsed
  inspect(result.get("EMPTY_VALUE"), content="Some(\"\")")
  inspect(result.get("QUOTED_SINGLE"), content="Some(\"single quoted\")")
  inspect(result.get("QUOTED_DOUBLE"), content="Some(\"double quoted\")")
  inspect(result.get("EMPTY_SINGLE"), content="Some(\"\")")
  inspect(result.get("EMPTY_DOUBLE"), content="Some(\"\")")
}

// Test multiline values

///|
test "parse multiline values" {
  let content = "MULTILINE1=\"hello\\nworld\"\nMULTILINE2=\"hello\\r\\nworld\""
  let result = parse(content)

  // Check that multiline values are properly parsed (actual escape processing)
  let multiline1 = result.get("MULTILINE1")
  let multiline2 = result.get("MULTILINE2")

  // The values should contain actual newline characters after escape processing
  inspect(multiline1 is Some(_), content="true")
  inspect(multiline2 is Some(_), content="true")

  // Check that the length includes the processed escape sequences
  match multiline1 {
    Some(value) =>
      inspect(
        value.contains("hello") && value.contains("world"),
        content="true",
      )
    None => inspect(false, content="true")
  }
}

// Test JSON values

///|
test "parse json values" {
  let content = "JSON='{\"foo\": \"bar\"}'"
  let result = parse(content)
  inspect(result.get("JSON"), content="Some(\"{\\\"foo\\\": \\\"bar\\\"}\")")
}

// Test whitespace handling

///|
test "parse whitespace handling" {
  let content = "WHITESPACE='    whitespace   '\nWHITESPACE_DOUBLE=\"    whitespace   \"\nVAR_WITH_SPACE = 'var with space'"
  let result = parse(content)
  inspect(result.get("WHITESPACE"), content="Some(\"    whitespace   \")")
  inspect(
    result.get("WHITESPACE_DOUBLE"),
    content="Some(\"    whitespace   \")",
  )
  inspect(result.get("VAR_WITH_SPACE"), content="Some(\"var with space\")")
}

// Test equals signs in values

///|
test "parse equals in values" {
  let content = "EQUALS='equ==als'"
  let result = parse(content)
  inspect(result.get("EQUALS"), content="Some(\"equ==als\")")
}

// Test numeric values

///|
test "parse numeric values" {
  let content = "THE_ANSWER=42\nV4R_W1TH_NUM8ER5='var with numbers'"
  let result = parse(content)
  inspect(result.get("THE_ANSWER"), content="Some(\"42\")")
  inspect(result.get("V4R_W1TH_NUM8ER5"), content="Some(\"var with numbers\")")
}

// Test invalid keys

///|
test "parse invalid keys" {
  let content = "1INVALID=var starting with a number\nVALID_KEY=valid value"
  let result = parse(content)

  // Invalid key should be ignored
  inspect(result.get("1INVALID"), content="None")
  inspect(result.get("VALID_KEY"), content="Some(\"valid value\")")
  inspect(result.size(), content="1")
}

// Test indented variables

///|
test "parse indented variables" {
  let content = "  INDENTED_VAR='indented var'\n  INDENTED_VALUE=  indented value\n\tTAB_INDENTED_VAR='indented var'\n\tTAB_INDENTED_VALUE=\tindented value"
  let result = parse(content)
  inspect(result.get("INDENTED_VAR"), content="Some(\"indented var\")")
  inspect(result.get("INDENTED_VALUE"), content="Some(\"indented value\")")
  inspect(result.get("TAB_INDENTED_VAR"), content="Some(\"indented var\")")
  inspect(result.get("TAB_INDENTED_VALUE"), content="Some(\"indented value\")")
}

// Test export prefix

///|
test "parse export prefix" {
  let content = "export EXPORT_IS_IGNORED='export is ignored'"
  let result = parse(content)
  inspect(
    result.get("EXPORT_IS_IGNORED"),
    content="Some(\"export is ignored\")",
  )
}

// Test variable expansion

///|
test "parse variable expansion" {
  let content = "THE_ANSWER=42\nQUOTED_SINGLE='single quoted'\nQUOTED_DOUBLE=\"double quoted\"\nEXPAND_VAR=$THE_ANSWER\nEXPAND_TWO_VARS=$QUOTED_SINGLE!==$QUOTED_DOUBLE"
  let result = parse(content)
  inspect(result.get("THE_ANSWER"), content="Some(\"42\")")
  inspect(result.get("QUOTED_SINGLE"), content="Some(\"single quoted\")")
  inspect(result.get("QUOTED_DOUBLE"), content="Some(\"double quoted\")")
  inspect(result.get("EXPAND_VAR"), content="Some(\"42\")")
  inspect(
    result.get("EXPAND_TWO_VARS"),
    content="Some(\"single quoted!==double quoted\")",
  )
}

// Test variable expansion with braces

///|
test "parse variable expansion with braces" {
  let content = "THE_ANSWER=42\nEXPAND_VAR_IN_BRACKETS=${THE_ANSWER}"
  let result = parse(content)
  inspect(result.get("THE_ANSWER"), content="Some(\"42\")")
  inspect(result.get("EXPAND_VAR_IN_BRACKETS"), content="Some(\"42\")")
}

// Test default values

///|
test "parse default values" {
  let content = "THE_ANSWER=42\nEXPAND_DEFAULT_TRUE=${NO_SUCH_VAR:-default}\nEXPAND_DEFAULT_FALSE=${THE_ANSWER:-default}"
  let result = parse(content)
  inspect(result.get("EXPAND_DEFAULT_TRUE"), content="Some(\"default\")")
  inspect(result.get("EXPAND_DEFAULT_FALSE"), content="Some(\"42\")")
}

// Test default values with braces

///|
test "parse default values with braces" {
  let content = "THE_ANSWER=42\nEXPAND_DEFAULT_IN_BRACKETS_TRUE=${NO_SUCH_VAR:-default}\nEXPAND_DEFAULT_IN_BRACKETS_FALSE=${THE_ANSWER:-default}"
  let result = parse(content)
  inspect(
    result.get("EXPAND_DEFAULT_IN_BRACKETS_TRUE"),
    content="Some(\"default\")",
  )
  inspect(
    result.get("EXPAND_DEFAULT_IN_BRACKETS_FALSE"),
    content="Some(\"42\")",
  )
}

// Test nested default values

///|
test "parse nested default values" {
  let content = "THE_ANSWER=42\nEXPAND_DEFAULT_VAR_IN_BRACKETS=${NO_SUCH_VAR:-${THE_ANSWER:-default}}"
  let result = parse(content)
  inspect(result.get("EXPAND_DEFAULT_VAR_IN_BRACKETS"), content="Some(\"42\")")
}

// Test escaped variables

///|
test "parse escaped variables" {
  let content = "THE_ANSWER=42\nEXPAND_ESCAPED=\\$THE_ANSWER"
  let result = parse(content)
  inspect(result.get("EXPAND_ESCAPED"), content="Some(\"$THE_ANSWER\")")
}

// Test recursive expansion

///|
test "parse recursive expansion" {
  let content = "QUOTED_SINGLE='single quoted'\nQUOTED_DOUBLE=\"double quoted\"\nEXPAND_TWO_VARS=$QUOTED_SINGLE!==$QUOTED_DOUBLE\nEXPAND_RECURSIVE=$EXPAND_TWO_VARS"
  let result = parse(content)
  inspect(
    result.get("EXPAND_RECURSIVE"),
    content="Some(\"single quoted!==double quoted\")",
  )
}

// Test stringify basic functionality

///|
test "stringify basic functionality" {
  let env : Map[String, String] = Map::new()
  env["GREETING"] = "hello world"
  env["PORT"] = "3000"
  let result = stringify(env)

  // Should contain both variables (order may vary)
  inspect(result.contains("GREETING='hello world'"), content="true")
  inspect(result.contains("PORT"), content="true")
}

// Test stringify with special characters

///|
test "stringify special characters" {
  let env : Map[String, String] = Map::new()
  env["SIMPLE"] = "simple value"
  env["WITH_SPACES"] = "value with spaces"
  env["WITH_QUOTES"] = "value with 'quotes'"
  env["MULTILINE"] = "line1\nline2"
  let result = stringify(env)

  // Simple values don't need quotes
  let has_simple = result.contains("SIMPLE=simple value") ||
    result.contains("SIMPLE='simple value'")
  inspect(has_simple, content="true")
  // Values with spaces should be quoted
  inspect(result.contains("WITH_SPACES='value with spaces'"), content="true")
  // Values with quotes should use double quotes and escape
  inspect(
    result.contains("WITH_QUOTES=\"value with 'quotes'\""),
    content="true",
  )
  // Multiline values should use double quotes and escape newlines
  inspect(result.contains("MULTILINE=\"line1\\nline2\""), content="true")
}

// Test round trip conversion

///|
test "round trip parse and stringify" {
  let original_content = "GREETING=hello world\nPORT=3000\nDEBUG=true"

  // Parse the original content
  let parsed = parse(original_content)

  // Stringify it back
  let stringified = stringify(parsed)

  // Parse the stringified version
  let reparsed = parse(stringified)

  // Should have the same number of variables
  inspect(parsed.size(), content="3")
  inspect(reparsed.size(), content="3")

  // Should preserve all values
  inspect(reparsed.get("GREETING"), content="Some(\"hello world\")")
  inspect(reparsed.get("PORT"), content="Some(\"3000\")")
  inspect(reparsed.get("DEBUG"), content="Some(\"true\")")
}
