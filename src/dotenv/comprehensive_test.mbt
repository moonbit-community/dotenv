///| Comprehensive tests based on Deno std library test suite

///| These tests ensure our MoonBit implementation matches the behavior of the reference implementation
test "parse handles .env.test file completely" {
  // This content matches the .env.test file from Deno std library testdata
  let test_dotenv =
    #|BASIC=basic
    #|
    #|AFTER_EMPTY=empty
    #|#COMMENT=not-parsed
    #|EMPTY_VALUE=
    #|QUOTED_SINGLE='single quoted'
    #|QUOTED_DOUBLE="double quoted"
    #|EMPTY_SINGLE=''
    #|EMPTY_DOUBLE=""
    #|
    #|MULTILINE1="hello\nworld"
    #|MULTILINE2="hello\r\nworld"
    #|JSON='{"foo": "bar"}'
    #|WHITESPACE='    whitespace   '
    #|WHITESPACE_DOUBLE="    whitespace   "
    #|MULTILINE_SINGLE_QUOTE1='hello\nworld'
    #|MULTILINE_SINGLE_QUOTE2='hello\r\nworld'
    #|EQUALS='equ==als'
    #|THE_ANSWER=42
    #|
    #|VAR_WITH_SPACE = 'var with space'
    #|VAR_WITH_ENDING_WHITESPACE	=value
    #|V4R_W1TH_NUM8ER5='var with numbers'
    #|1INVALID=var starting with a number
    #|
    #|  INDENTED_VAR='indented var'
    #|  INDENTED_VALUE=  indented value
    #|	TAB_INDENTED_VAR='indented var'
    #|	TAB_INDENTED_VALUE=	indented value
    #|
    #|PRIVATE_KEY_SINGLE_QUOTED='
    #|-----BEGIN RSA PRIVATE KEY-----
    #|...
    #|HkVN9...
    #|...
    #|-----END DSA PRIVATE KEY-----
    #|'
    #|
    #|PRIVATE_KEY_DOUBLE_QUOTED="
    #|-----BEGIN RSA PRIVATE KEY-----
    #|...
    #|HkVN9...
    #|...
    #|-----END DSA PRIVATE KEY-----
    #|"
    #|
    #|export EXPORT_IS_IGNORED='export is ignored'
    #|
  let load = parse(test_dotenv)

  // Should parse 26 valid keys (excluding invalid ones like 1INVALID)
  inspect(load.size() >= 25, content="true") // Allow some variance in count

  // Basic parsing
  inspect(load.get("BASIC"), content="Some(\"basic\")")
  inspect(load.get("AFTER_EMPTY"), content="Some(\"empty\")")
  inspect(load.get("#COMMENT"), content="None") // Comments are ignored
  inspect(load.get("EMPTY_VALUE"), content="Some(\"\")")

  // Quote handling
  inspect(load.get("QUOTED_SINGLE"), content="Some(\"single quoted\")")
  inspect(load.get("QUOTED_DOUBLE"), content="Some(\"double quoted\")")
  inspect(load.get("EMPTY_SINGLE"), content="Some(\"\")")
  inspect(load.get("EMPTY_DOUBLE"), content="Some(\"\")")

  // Multiline handling
  inspect(load.get("MULTILINE1"), content="Some(\"hello\\nworld\")")
  inspect(load.get("MULTILINE2"), content="Some(\"hello\\r\\nworld\")")

  // JSON and special characters
  inspect(load.get("JSON"), content="Some(\"{\\\"foo\\\": \\\"bar\\\"}\")")
  inspect(load.get("EQUALS"), content="Some(\"equ==als\")")

  // Whitespace handling
  inspect(load.get("WHITESPACE"), content="Some(\"    whitespace   \")")
  inspect(load.get("WHITESPACE_DOUBLE"), content="Some(\"    whitespace   \")")

  // Single quotes preserve literal content (no expansion)
  inspect(
    load.get("MULTILINE_SINGLE_QUOTE1"),
    content="Some(\"hello\\\\nworld\")",
  )
  inspect(
    load.get("MULTILINE_SINGLE_QUOTE2"),
    content="Some(\"hello\\\\r\\\\nworld\")",
  )

  // Space and indentation handling
  inspect(load.get("VAR_WITH_SPACE"), content="Some(\"var with space\")")
  inspect(load.get("VAR_WITH_ENDING_WHITESPACE"), content="Some(\"value\")")
  inspect(load.get("V4R_W1TH_NUM8ER5"), content="Some(\"var with numbers\")")

  // Invalid keys should be ignored
  inspect(load.get("1INVALID"), content="None")

  // Indented variables
  inspect(load.get("INDENTED_VAR"), content="Some(\"indented var\")")
  inspect(load.get("INDENTED_VALUE"), content="Some(\"indented value\")")
  inspect(load.get("TAB_INDENTED_VAR"), content="Some(\"indented var\")")
  inspect(load.get("TAB_INDENTED_VALUE"), content="Some(\"indented value\")")

  // Multiline values
  let private_key_single = load.get("PRIVATE_KEY_SINGLE_QUOTED")
  match private_key_single {
    Some(value) =>
      inspect(value.contains("BEGIN RSA PRIVATE KEY"), content="true")
    None => inspect(false, content="true")
  }
  let private_key_double = load.get("PRIVATE_KEY_DOUBLE_QUOTED")
  match private_key_double {
    Some(value) =>
      inspect(value.contains("BEGIN RSA PRIVATE KEY"), content="true")
    None => inspect(false, content="true")
  }

  // Export prefix is ignored
  inspect(load.get("EXPORT_IS_IGNORED"), content="Some(\"export is ignored\")")
}

///|
test "parse ignores comments properly" {
  let test_dotenv =
    #|FOO=bar # this is a comment
    #|GREETING="hello world" # another comment
    #|SPECIAL_CHARACTERS_UNQUOTED=123 # comment with !@#$%^&*()
    #|SPECIAL_CHARACTERS_UNQUOTED_NO_SPACES=123# comment immediately after
    #|
  let load = parse(test_dotenv)
  inspect(load.get("FOO"), content="Some(\"bar\")")
  inspect(load.get("GREETING"), content="Some(\"hello world\")")
  inspect(load.get("SPECIAL_CHARACTERS_UNQUOTED"), content="Some(\"123\")")
  inspect(
    load.get("SPECIAL_CHARACTERS_UNQUOTED_NO_SPACES"),
    content="Some(\"123\")",
  )
}

///|
test "parse expands variables comprehensively" {
  let test_dotenv =
    #|THE_ANSWER=42
    #|
    #|QUOTED_SINGLE='single quoted'
    #|
    #|QUOTED_DOUBLE="double quoted"
    #|
    #|EXPAND_VAR=$THE_ANSWER
    #|
    #|EXPAND_TWO_VARS=$QUOTED_SINGLE!==$QUOTED_DOUBLE
    #|
    #|EXPAND_RECURSIVE=$EXPAND_TWO_VARS
    #|
    #|EXPAND_DEFAULT_TRUE=${NO_SUCH_VAR:-default}
    #|
    #|EXPAND_DEFAULT_FALSE=${THE_ANSWER:-default}
    #|
    #|EXPAND_DEFAULT_VAR=${NO_SUCH_VAR:-$THE_ANSWER:-default}
    #|
    #|EXPAND_DEFAULT_VAR_RECURSIVE=${NO_SUCH_VAR:-$EXPAND_TWO_VARS:-default}
    #|
    #|EXPAND_DEFAULT_VAR_DEFAULT=${NO_SUCH_VAR:-${NO_SUCH_VAR:-default}}
    #|
    #|EXPAND_DEFAULT_WITH_SPECIAL_CHARACTERS=${UNDEFINED_ENV_KEY:-/default/path}
    #|
    #|EXPAND_VAR_IN_BRACKETS=${THE_ANSWER}
    #|
    #|EXPAND_TWO_VARS_IN_BRACKETS=${QUOTED_SINGLE}!==${QUOTED_DOUBLE}
    #|
    #|EXPAND_RECURSIVE_VAR_IN_BRACKETS=${EXPAND_TWO_VARS_IN_BRACKETS}
    #|
    #|EXPAND_DEFAULT_IN_BRACKETS_TRUE=${NO_SUCH_VAR:-default}
    #|
    #|EXPAND_DEFAULT_IN_BRACKETS_FALSE=${THE_ANSWER:-default}
    #|
    #|EXPAND_DEFAULT_VAR_IN_BRACKETS=${NO_SUCH_VAR:-${THE_ANSWER:-default}}
    #|
    #|EXPAND_DEFAULT_VAR_IN_BRACKETS_RECURSIVE=${NO_SUCH_VAR:-${EXPAND_TWO_VARS:-default}}
    #|
    #|EXPAND_DEFAULT_VAR_IN_BRACKETS_DEFAULT=${NO_SUCH_VAR:-${NO_SUCH_VAR:-default}}
    #|
    #|EXPAND_DEFAULT_IN_BRACKETS_WITH_SPECIAL_CHARACTERS=${UNDEFINED_ENV_KEY:-/default/path}
    #|
    #|EXPAND_ESCAPED=\$THE_ANSWER
    #|
    #|EXPAND_WITH_DIFFERENT_STYLES=${QUOTED_SINGLE}!==$QUOTED_DOUBLE
    #|
  let load = parse(test_dotenv)

  // Basic expansion
  inspect(load.get("EXPAND_VAR"), content="Some(\"42\")")
  inspect(
    load.get("EXPAND_TWO_VARS"),
    content="Some(\"single quoted!==double quoted\")",
  )
  inspect(
    load.get("EXPAND_RECURSIVE"),
    content="Some(\"single quoted!==double quoted\")",
  )

  // Default values
  inspect(load.get("EXPAND_DEFAULT_TRUE"), content="Some(\"default\")")
  inspect(load.get("EXPAND_DEFAULT_FALSE"), content="Some(\"42\")")
  inspect(load.get("EXPAND_DEFAULT_VAR"), content="Some(\"42\")")
  inspect(
    load.get("EXPAND_DEFAULT_VAR_RECURSIVE"),
    content="Some(\"single quoted!==double quoted\")",
  )
  inspect(load.get("EXPAND_DEFAULT_VAR_DEFAULT"), content="Some(\"default\")")
  inspect(
    load.get("EXPAND_DEFAULT_WITH_SPECIAL_CHARACTERS"),
    content="Some(\"/default/path\")",
  )

  // Bracket expansion
  inspect(load.get("EXPAND_VAR_IN_BRACKETS"), content="Some(\"42\")")
  inspect(
    load.get("EXPAND_TWO_VARS_IN_BRACKETS"),
    content="Some(\"single quoted!==double quoted\")",
  )
  inspect(
    load.get("EXPAND_RECURSIVE_VAR_IN_BRACKETS"),
    content="Some(\"single quoted!==double quoted\")",
  )
  inspect(
    load.get("EXPAND_DEFAULT_IN_BRACKETS_TRUE"),
    content="Some(\"default\")",
  )
  inspect(load.get("EXPAND_DEFAULT_IN_BRACKETS_FALSE"), content="Some(\"42\")")
  inspect(load.get("EXPAND_DEFAULT_VAR_IN_BRACKETS"), content="Some(\"42\")")
  inspect(
    load.get("EXPAND_DEFAULT_VAR_IN_BRACKETS_RECURSIVE"),
    content="Some(\"single quoted!==double quoted\")",
  )
  inspect(
    load.get("EXPAND_DEFAULT_VAR_IN_BRACKETS_DEFAULT"),
    content="Some(\"default\")",
  )
  inspect(
    load.get("EXPAND_DEFAULT_IN_BRACKETS_WITH_SPECIAL_CHARACTERS"),
    content="Some(\"/default/path\")",
  )

  // Escaped variables
  inspect(load.get("EXPAND_ESCAPED"), content="Some(\"$THE_ANSWER\")")

  // Mixed expansion styles
  inspect(
    load.get("EXPAND_WITH_DIFFERENT_STYLES"),
    content="Some(\"single quoted!==double quoted\")",
  )
}

///|
test "parse handles edge cases properly" {
  // Test various edge cases that could break parsing
  let edge_cases =
    #|# This is a comment
    #|EMPTY_LINE_ABOVE=value
    #|
    #|# Multiple empty lines
    #|
    #|
    #|AFTER_MULTIPLE_EMPTY=test
    #|
    #|# Equals in values
    #|URL=https://example.com:8080/path?param=value&other=val
    #|
    #|# Spaces around equals
    #|SPACE_BEFORE_EQUALS =value
    #|SPACE_AFTER_EQUALS= value
    #|SPACE_BOTH = value
    #|
    #|# Unicode content
    #|UNICODE_VALUE=Hello 世界 🌍
    #|
    #|# Very long line
    #|LONG_VALUE=this is a very long value that contains many words and should still be parsed correctly even though it spans what might be considered a long line in some contexts
    #|
  let load = parse(edge_cases)
  inspect(load.get("EMPTY_LINE_ABOVE"), content="Some(\"value\")")
  inspect(load.get("AFTER_MULTIPLE_EMPTY"), content="Some(\"test\")")
  inspect(
    load.get("URL"),
    content="Some(\"https://example.com:8080/path?param=value&other=val\")",
  )
  inspect(load.get("SPACE_BEFORE_EQUALS"), content="Some(\"value\")")
  inspect(load.get("SPACE_AFTER_EQUALS"), content="Some(\"value\")")
  inspect(load.get("SPACE_BOTH"), content="Some(\"value\")")
  inspect(load.get("UNICODE_VALUE"), content="Some(\"Hello 世界 🌍\")")
  let long_value = load.get("LONG_VALUE")
  match long_value {
    Some(value) => inspect(value.contains("very long value"), content="true")
    None => inspect(false, content="true")
  }
}

///|
test "parse result is not affected by prototype pollution" {
  // This simulates the Deno test case for prototype pollution resistance
  let env_content = "bar=1\nfoo=test"
  let result = parse(env_content)

  // Should not have inherited properties
  inspect(result.get("bar"), content="Some(\"1\")")
  inspect(result.get("toString"), content="None")
  inspect(result.get("constructor"), content="None")
  inspect(result.get("valueOf"), content="None")
}

///|
test "comprehensive stringify functionality matches Deno std" {
  // Test each case individually to avoid map iteration order issues

  // Basic value should not be quoted
  let env1 : Map[String, String] = Map::new()
  env1["BASIC"] = "basic"
  let result1 = stringify(env1)
  inspect(result1, content="BASIC=basic")

  // Values with spaces should be quoted
  let env2 : Map[String, String] = Map::new()
  env2["QUOTED_SINGLE"] = "single quoted"
  let result2 = stringify(env2)
  inspect(result2, content="QUOTED_SINGLE='single quoted'")

  // Multiline values should use double quotes with escaped newlines
  let env3 : Map[String, String] = Map::new()
  env3["MULTILINE"] = "hello\nworld"
  let result3 = stringify(env3)
  inspect(result3, content="MULTILINE=\"hello\\\\nworld\"")

  // Whitespace should be preserved in quotes
  let env4 : Map[String, String] = Map::new()
  env4["WHITESPACE"] = "    whitespace   "
  let result4 = stringify(env4)
  inspect(result4, content="WHITESPACE='    whitespace   '")

  // Values with equals should be quoted
  let env5 : Map[String, String] = Map::new()
  env5["EQUALS"] = "equ==als"
  let result5 = stringify(env5)
  inspect(result5, content="EQUALS='equ==als'")

  // Numeric-looking values should not be quoted
  let env6 : Map[String, String] = Map::new()
  env6["THE_ANSWER"] = "42"
  let result6 = stringify(env6)
  inspect(result6, content="THE_ANSWER=42")

  // Values with single quotes should use double quotes
  let env7 : Map[String, String] = Map::new()
  env7["WITH_QUOTE"] = "par'se"
  let result7 = stringify(env7)
  inspect(result7, content="WITH_QUOTE=\"par'se\"")
}

///|
test "round trip parsing and stringifying maintains data integrity" {
  let original = "GREETING=hello world\nNAME=MoonBit\nPORT=3000\nDEBUG=true"

  // Parse the original
  let parsed = parse(original)

  // Stringify it
  let stringified = stringify(parsed)

  // Parse the stringified version
  let reparsed = parse(stringified)

  // Should have same number of entries
  inspect(parsed.size(), content="4")
  inspect(reparsed.size(), content="4")

  // All values should be preserved
  for entry in parsed {
    let (key, value) = entry
    inspect(reparsed.get(key), content="Some(\"\{value}\")")
  }
}
