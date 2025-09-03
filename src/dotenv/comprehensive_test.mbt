///| Comprehensive tests for the dotenv module matching Deno std library behavior
test "parse() comprehensive test using .env.test file format" {
  // This mimics the comprehensive test from the Deno std library
  let test_dotenv = "BASIC=basic\n\nAFTER_EMPTY=empty\n#COMMENT=not-parsed\nEMPTY_VALUE=\nQUOTED_SINGLE='single quoted'\nQUOTED_DOUBLE=\"double quoted\"\nEMPTY_SINGLE=''\nEMPTY_DOUBLE=\"\"\n\nMULTILINE1=\"hello\\nworld\"\nMULTILINE2=\"hello\\r\\nworld\"\nJSON='{\"foo\": \"bar\"}'\nWHITESPACE='    whitespace   '\nWHITESPACE_DOUBLE=\"    whitespace   \"\nMULTILINE_SINGLE_QUOTE1='hello\\nworld'\nMULTILINE_SINGLE_QUOTE2='hello\\r\\nworld'\nEQUALS='equ==als'\nTHE_ANSWER=42\n\nVAR_WITH_SPACE = 'var with space'\nVAR_WITH_ENDING_WHITESPACE\t=value\nV4R_W1TH_NUM8ER5='var with numbers'\n1INVALID=var starting with a number\n\n  INDENTED_VAR='indented var'\n  INDENTED_VALUE=  indented value\n\tTAB_INDENTED_VAR='indented var'\n\tTAB_INDENTED_VALUE=\tindented value\n\nPRIVATE_KEY_SINGLE_QUOTED='\n-----BEGIN RSA PRIVATE KEY-----\n...\nHkVN9...\n...\n-----END DSA PRIVATE KEY-----\n'\n\nPRIVATE_KEY_DOUBLE_QUOTED=\"\n-----BEGIN RSA PRIVATE KEY-----\n...\nHkVN9...\n...\n-----END DSA PRIVATE KEY-----\n\"\n\nexport EXPORT_IS_IGNORED='export is ignored'"
  let load = parse(test_dotenv)

  // Test that we parse the expected number of valid keys (26 from Deno std test)
  // Note: 1INVALID should be skipped due to invalid key pattern
  inspect(load.size(), content="26")

  // Basic tests
  inspect(load.get("BASIC"), content="Some(\"basic\")")
  inspect(load.get("AFTER_EMPTY"), content="Some(\"empty\")")
  inspect(load.get("#COMMENT"), content="None") // Comments should not be parsed
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

  // Whitespace preservation
  inspect(load.get("WHITESPACE"), content="Some(\"    whitespace   \")")
  inspect(load.get("WHITESPACE_DOUBLE"), content="Some(\"    whitespace   \")")

  // Single quotes preserve literal content (no escape expansion)
  inspect(
    load.get("MULTILINE_SINGLE_QUOTE1"),
    content="Some(\"hello\\\\nworld\")",
  )
  inspect(
    load.get("MULTILINE_SINGLE_QUOTE2"),
    content="Some(\"hello\\\\r\\\\nworld\")",
  )

  // Special characters
  inspect(load.get("EQUALS"), content="Some(\"equ==als\")")

  // Whitespace and formatting
  inspect(load.get("VAR_WITH_SPACE"), content="Some(\"var with space\")")
  inspect(load.get("VAR_WITH_ENDING_WHITESPACE"), content="Some(\"value\")")
  inspect(load.get("V4R_W1TH_NUM8ER5"), content="Some(\"var with numbers\")")

  // Invalid keys should be ignored
  inspect(load.get("1INVALID"), content="None")

  // Indentation handling
  inspect(load.get("INDENTED_VAR"), content="Some(\"indented var\")")
  inspect(load.get("INDENTED_VALUE"), content="Some(\"indented value\")")
  inspect(load.get("TAB_INDENTED_VAR"), content="Some(\"indented var\")")
  inspect(load.get("TAB_INDENTED_VALUE"), content="Some(\"indented value\")")

  // Multiline private keys
  inspect(
    load.get("PRIVATE_KEY_SINGLE_QUOTED"),
    content="Some(\"\\n-----BEGIN RSA PRIVATE KEY-----\\n...\\nHkVN9...\\n...\\n-----END DSA PRIVATE KEY-----\\n\")",
  )
  inspect(
    load.get("PRIVATE_KEY_DOUBLE_QUOTED"),
    content="Some(\"\\n-----BEGIN RSA PRIVATE KEY-----\\n...\\nHkVN9...\\n...\\n-----END DSA PRIVATE KEY-----\\n\")",
  )

  // Export prefix handling
  inspect(load.get("EXPORT_IS_IGNORED"), content="Some(\"export is ignored\")")
}

///|
test "parse() handles comments correctly" {
  let test_dotenv = "FOO=bar # comment\nGREETING=\"hello world\" # another comment\nSPECIAL_CHARACTERS_UNQUOTED=123 # !@#$%^&*()\nSPECIAL_CHARACTERS_UNQUOTED_NO_SPACES=123# right after value"
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
test "parse() expands variables comprehensively" {
  let test_dotenv = "THE_ANSWER=42\n\nQUOTED_SINGLE='single quoted'\n\nQUOTED_DOUBLE=\"double quoted\"\n\nEXPAND_VAR=$THE_ANSWER\n\nEXPAND_TWO_VARS=$QUOTED_SINGLE!==$QUOTED_DOUBLE\n\nEXPAND_RECURSIVE=$EXPAND_TWO_VARS\n\nEXPAND_DEFAULT_TRUE=$NO_SUCH_VAR:-default\n\nEXPAND_DEFAULT_FALSE=$THE_ANSWER:-default\n\nEXPAND_DEFAULT_VAR=$NO_SUCH_VAR:-$THE_ANSWER:-default\n\nEXPAND_DEFAULT_VAR_RECURSIVE=$NO_SUCH_VAR:-$EXPAND_TWO_VARS:-default\n\nEXPAND_DEFAULT_VAR_DEFAULT=$NO_SUCH_VAR:-$NO_SUCH_VAR:-default\n\nEXPAND_DEFAULT_WITH_SPECIAL_CHARACTERS=$UNDEFINED_ENV_KEY:-/default/path\n\nEXPAND_VAR_IN_BRACKETS=\\${THE_ANSWER}\n\nEXPAND_TWO_VARS_IN_BRACKETS=\\${QUOTED_SINGLE}!==$QUOTED_DOUBLE\n\nEXPAND_RECURSIVE_VAR_IN_BRACKETS=\\${EXPAND_TWO_VARS_IN_BRACKETS}\n\nEXPAND_DEFAULT_IN_BRACKETS_TRUE=\\${NO_SUCH_VAR:-default}\n\nEXPAND_DEFAULT_IN_BRACKETS_FALSE=\\${THE_ANSWER:-default}\n\nEXPAND_DEFAULT_VAR_IN_BRACKETS=\\${NO_SUCH_VAR:-\\${THE_ANSWER:-default}}\n\nEXPAND_DEFAULT_VAR_IN_BRACKETS_RECURSIVE=\\${NO_SUCH_VAR:-\\${EXPAND_TWO_VARS:-default}}\n\nEXPAND_DEFAULT_VAR_IN_BRACKETS_DEFAULT=\\${NO_SUCH_VAR:-\\${NO_SUCH_VAR:-default}}\n\nEXPAND_DEFAULT_IN_BRACKETS_WITH_SPECIAL_CHARACTERS=\\${UNDEFINED_ENV_KEY:-/default/path}\n\nEXPAND_ESCAPED=\\\\$THE_ANSWER\n\nEXPAND_WITH_DIFFERENT_STYLES=\\${QUOTED_SINGLE}!==$QUOTED_DOUBLE"
  let load = parse(test_dotenv)

  // Basic variable expansion
  inspect(load.get("EXPAND_VAR"), content="Some(\"42\")")

  // Multiple variable expansion
  inspect(
    load.get("EXPAND_TWO_VARS"),
    content="Some(\"single quoted!==double quoted\")",
  )

  // Recursive expansion
  inspect(
    load.get("EXPAND_RECURSIVE"),
    content="Some(\"single quoted!==double quoted\")",
  )

  // Default value handling
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

  // Bracket notation
  inspect(load.get("EXPAND_VAR_IN_BRACKETS"), content=(
    #|Some("${THE_ANSWER}")
  ))
  inspect(
    load.get("EXPAND_TWO_VARS_IN_BRACKETS"),
    content=(
      #|Some("${QUOTED_SINGLE}!==double quoted")
    ),
  )
  inspect(
    load.get("EXPAND_RECURSIVE_VAR_IN_BRACKETS"),
    content=(
      #|Some("${EXPAND_TWO_VARS_IN_BRACKETS}")
    ),
  )

  // Default values with brackets
  inspect(
    load.get("EXPAND_DEFAULT_IN_BRACKETS_TRUE"),
    content=(
      #|Some("${NO_SUCH_VAR:-default}")
    ),
  )
  inspect(load.get("EXPAND_DEFAULT_IN_BRACKETS_FALSE"), content=(
    #|Some("${THE_ANSWER:-default}")
  ))
  inspect(load.get("EXPAND_DEFAULT_VAR_IN_BRACKETS"), content=(
    #|Some("${NO_SUCH_VAR:-${THE_ANSWER:-default}}")
  ))
  inspect(
    load.get("EXPAND_DEFAULT_VAR_IN_BRACKETS_RECURSIVE"),
    content=(
      #|Some("${NO_SUCH_VAR:-${EXPAND_TWO_VARS:-default}}")
    ),
  )
  inspect(
    load.get("EXPAND_DEFAULT_VAR_IN_BRACKETS_DEFAULT"),
    content=(
      #|Some("${NO_SUCH_VAR:-${NO_SUCH_VAR:-default}}")
    ),
  )
  inspect(
    load.get("EXPAND_DEFAULT_IN_BRACKETS_WITH_SPECIAL_CHARACTERS"),
    content=(
      #|Some("${UNDEFINED_ENV_KEY:-/default/path}")
    ),
  )

  // Escaped variables
  inspect(load.get("EXPAND_ESCAPED"), content=(
    #|Some("\\$THE_ANSWER")
  ))

  // Mixed styles
  inspect(
    load.get("EXPAND_WITH_DIFFERENT_STYLES"),
    content=(
      #|Some("${QUOTED_SINGLE}!==double quoted")
    ),
  )
}

///|
test "parse() preserves whitespace in quoted values" {
  let env_content = "WHITESPACE_SINGLE='  leading and trailing  '\nWHITESPACE_DOUBLE=\"  leading and trailing  \"\nTRIM_UNQUOTED=  should be trimmed  "
  let result = parse(env_content)
  inspect(
    result.get("WHITESPACE_SINGLE"),
    content="Some(\"  leading and trailing  \")",
  )
  inspect(
    result.get("WHITESPACE_DOUBLE"),
    content="Some(\"  leading and trailing  \")",
  )
  inspect(result.get("TRIM_UNQUOTED"), content="Some(\"should be trimmed\")")
}

///|
test "parse() handles JSON values correctly" {
  let env_content = "JSON_SINGLE='{\"foo\": \"bar\", \"nested\": {\"key\": \"value\"}}'\nJSON_DOUBLE=\"{\\\"escape\\\": \\\"test\\\"}\""
  let result = parse(env_content)
  inspect(
    result.get("JSON_SINGLE"),
    content="Some(\"{\\\"foo\\\": \\\"bar\\\", \\\"nested\\\": {\\\"key\\\": \\\"value\\\"}}\")",
  )
  inspect(
    result.get("JSON_DOUBLE"),
    content="Some(\"{\\\"escape\\\": \\\"test\\\"}\")",
  )
}

///|
test "parse() handles edge cases" {
  let env_content = "ONLY_KEY=\nEQUAL_IN_VALUE=value=with=equals\nHASH_IN_VALUE=value#with#hash\nEXPORT_SPACE= export VAR_NAME=value\nSPACES_AROUND_EQUALS = value = extra\nMULTIPLE_EQUALS=first=second=third"
  let result = parse(env_content)
  inspect(result.get("ONLY_KEY"), content="Some(\"\")")
  inspect(result.get("EQUAL_IN_VALUE"), content="Some(\"value=with=equals\")")
  inspect(result.get("HASH_IN_VALUE"), content="Some(\"value\")")
  inspect(result.get("SPACES_AROUND_EQUALS"), content="Some(\"value = extra\")")
  inspect(result.get("MULTIPLE_EQUALS"), content="Some(\"first=second=third\")")
}

///|
test "parse() result is not affected by Map prototype pollution" {
  // This test ensures our Map implementation behaves correctly
  // and doesn't have unexpected properties
  let result = parse("bar=1")

  // Should only contain the parsed key
  inspect(result.size(), content="1")
  inspect(result.get("bar"), content="Some(\"1\")")

  // Should not contain any prototype pollution
  inspect(result.get("constructor"), content="None")
  inspect(result.get("toString"), content="None")
  inspect(result.get("valueOf"), content="None")
}

///|
test "stringify() produces output that can be round-tripped" {
  let original_env = Map::new()
  original_env["BASIC"] = "basic"
  original_env["QUOTED"] = "hello world"
  original_env["MULTILINE"] = "line1\nline2"
  original_env["SPECIAL"] = "value with spaces"
  let stringified = stringify(original_env)
  let reparsed = parse(stringified)
  inspect(reparsed.get("BASIC"), content="Some(\"basic\")")
  inspect(reparsed.get("QUOTED"), content="Some(\"hello world\")")
  inspect(reparsed.get("MULTILINE"), content=(
    #|Some("line1\\\nline2")
  ))
  inspect(reparsed.get("SPECIAL"), content="Some(\"value with spaces\")")
}

///|
test "LoadOptions functionality" {
  let default_opts = LoadOptions::default()
  inspect(default_opts.env_path, content="Some(\".env\")")
  inspect(default_opts.export_vars, content="false")
  let custom_opts = LoadOptions::with_path(".env.test")
  inspect(custom_opts.env_path, content="Some(\".env.test\")")
  inspect(custom_opts.export_vars, content="false")
  let export_opts = LoadOptions::with_export()
  inspect(export_opts.env_path, content="Some(\".env\")")
  inspect(export_opts.export_vars, content="true")
  let full_opts = LoadOptions::with_path_and_export(".env.prod")
  inspect(full_opts.env_path, content="Some(\".env.prod\")")
  inspect(full_opts.export_vars, content="true")
  let no_file_opts = LoadOptions::no_file()
  inspect(no_file_opts.env_path, content="None")
  inspect(no_file_opts.export_vars, content="false")
}

///|
test "load_from_string functionality" {
  let content = "GREETING=hello world\nPORT=3000\nDEBUG=true"
  let conf = load_from_string(content)
  inspect(conf.size(), content="3")
  inspect(conf.get("GREETING"), content="Some(\"hello world\")")
  inspect(conf.get("PORT"), content="Some(\"3000\")")
  inspect(conf.get("DEBUG"), content="Some(\"true\")")

  // Test with export option
  let export_opts = LoadOptions::with_export()
  let conf_export = load_from_string(content, options=export_opts)
  inspect(conf_export.size(), content="3")
  inspect(conf_export.get("GREETING"), content="Some(\"hello world\")")
}
