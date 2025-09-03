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
test "parse handles escaped variables with backslash correctly" {
  let env_content = "THE_ANSWER=42\nESCAPED1=\\$THE_ANSWER\nESCAPED2=prefix \\$THE_ANSWER suffix"
  let result = parse(env_content)
  inspect(result.get("ESCAPED1"), content="Some(\"$THE_ANSWER\")")
  inspect(result.get("ESCAPED2"), content="Some(\"prefix $THE_ANSWER suffix\")")
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
  inspect(result.get("DOUBLE_QUOTED"), content="Some(\"Value is 42\")")
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

///| Test comprehensive .env.test file parsing to match reference implementation
test "parse handles complete .env.test file" {
  let test_content = "BASIC=basic\n\nAFTER_EMPTY=empty\n#COMMENT=not-parsed\nEMPTY_VALUE=\nQUOTED_SINGLE='single quoted'\nQUOTED_DOUBLE=\"double quoted\"\nEMPTY_SINGLE=''\nEMPTY_DOUBLE=\"\"\n\nMULTILINE1=\"hello\\nworld\"\nMULTILINE2=\"hello\\r\\nworld\"\nJSON='{\"foo\": \"bar\"}'\nWHITESPACE='    whitespace   '\nWHITESPACE_DOUBLE=\"    whitespace   \"\nMULTILINE_SINGLE_QUOTE1='hello\\nworld'\nMULTILINE_SINGLE_QUOTE2='hello\\r\\nworld'\nEQUALS='equ==als'\nTHE_ANSWER=42\n\nVAR_WITH_SPACE = 'var with space'\nVAR_WITH_ENDING_WHITESPACE\t=value\nV4R_W1TH_NUM8ER5='var with numbers'\n1INVALID=var starting with a number\n\n  INDENTED_VAR='indented var'\n  INDENTED_VALUE=  indented value\n\tTAB_INDENTED_VAR='indented var'\n\tTAB_INDENTED_VALUE=\tindented value\n\nPRIVATE_KEY_SINGLE_QUOTED='\n-----BEGIN RSA PRIVATE KEY-----\n...\nHkVN9...\n...\n-----END DSA PRIVATE KEY-----\n'\n\nPRIVATE_KEY_DOUBLE_QUOTED=\"\n-----BEGIN RSA PRIVATE KEY-----\n...\nHkVN9...\n...\n-----END DSA PRIVATE KEY-----\n\"\n\nexport EXPORT_IS_IGNORED='export is ignored'"
  let result = parse(test_content)

  // Should parse 26 valid keys according to reference tests
  inspect(result.size(), content="26")

  // Test key-value parsing
  inspect(result.get("BASIC"), content="Some(\"basic\")")
  inspect(result.get("AFTER_EMPTY"), content="Some(\"empty\")")
  inspect(result.get("#COMMENT"), content="None") // Comments should be ignored
  inspect(result.get("EMPTY_VALUE"), content="Some(\"\")")

  // Test quote handling
  inspect(result.get("QUOTED_SINGLE"), content="Some(\"single quoted\")")
  inspect(result.get("QUOTED_DOUBLE"), content="Some(\"double quoted\")")
  inspect(result.get("EMPTY_SINGLE"), content="Some(\"\")")
  inspect(result.get("EMPTY_DOUBLE"), content="Some(\"\")")

  // Test multiline values and escape sequences
  inspect(result.get("MULTILINE1"), content="Some(\"hello\\nworld\")")
  inspect(result.get("MULTILINE2"), content="Some(\"hello\\r\\nworld\")")
  inspect(result.get("JSON"), content="Some(\"{\\\"foo\\\": \\\"bar\\\"}\")")

  // Test whitespace preservation in quotes
  inspect(result.get("WHITESPACE"), content="Some(\"    whitespace   \")")
  inspect(
    result.get("WHITESPACE_DOUBLE"),
    content="Some(\"    whitespace   \")",
  )

  // Test equals in values
  inspect(result.get("EQUALS"), content="Some(\"equ==als\")")

  // Test whitespace handling
  inspect(result.get("VAR_WITH_SPACE"), content="Some(\"var with space\")")
  inspect(result.get("VAR_WITH_ENDING_WHITESPACE"), content="Some(\"value\")")

  // Test alphanumeric variables
  inspect(result.get("V4R_W1TH_NUM8ER5"), content="Some(\"var with numbers\")")
  inspect(result.get("1INVALID"), content="None") // Invalid key should be ignored

  // Test indented variables
  inspect(result.get("INDENTED_VAR"), content="Some(\"indented var\")")
  inspect(result.get("INDENTED_VALUE"), content="Some(\"indented value\")")
  inspect(result.get("TAB_INDENTED_VAR"), content="Some(\"indented var\")")
  inspect(result.get("TAB_INDENTED_VALUE"), content="Some(\"indented value\")")

  // Test multiline private keys
  inspect(
    result.get("PRIVATE_KEY_SINGLE_QUOTED"),
    content="Some(\"\\n-----BEGIN RSA PRIVATE KEY-----\\n...\\nHkVN9...\\n...\\n-----END DSA PRIVATE KEY-----\\n\")",
  )
  inspect(
    result.get("PRIVATE_KEY_DOUBLE_QUOTED"),
    content="Some(\"\\n-----BEGIN RSA PRIVATE KEY-----\\n...\\nHkVN9...\\n...\\n-----END DSA PRIVATE KEY-----\\n\")",
  )

  // Test export handling
  inspect(
    result.get("EXPORT_IS_IGNORED"),
    content="Some(\"export is ignored\")",
  )
}

///| Test comments parsing
test "parse ignores comments correctly" {
  let comments_content = "# This is a comment\nFOO=bar # This is an inline comment\nGREETING= \"hello world\" # hello world\nSPECIAL_CHARACTERS_UNQUOTED=123 #Some text !@# [] \nSPECIAL_CHARACTERS_UNQUOTED_NO_SPACES=123#Some text !@# [] "
  let result = parse(comments_content)
  inspect(result.get("FOO"), content="Some(\"bar\")")
  inspect(result.get("GREETING"), content="Some(\"hello world\")")
  inspect(result.get("SPECIAL_CHARACTERS_UNQUOTED"), content="Some(\"123\")")
  inspect(
    result.get("SPECIAL_CHARACTERS_UNQUOTED_NO_SPACES"),
    content="Some(\"123\")",
  )
}

///| Test comprehensive variable expansion from .env.expand.test
test "parse handles comprehensive expansion" {
  let expand_content = "THE_ANSWER=42\n\nQUOTED_SINGLE='single quoted'\n\nQUOTED_DOUBLE=\"double quoted\"\n\nEXPAND_VAR=$THE_ANSWER\n\nEXPAND_TWO_VARS=$QUOTED_SINGLE!==$QUOTED_DOUBLE\n\nEXPAND_RECURSIVE=$EXPAND_TWO_VARS\n\nEXPAND_DEFAULT_TRUE=$NO_SUCH_VAR:-default\n\nEXPAND_DEFAULT_FALSE=$THE_ANSWER:-default\n\nEXPAND_DEFAULT_VAR=$NO_SUCH_VAR:-$THE_ANSWER:-default\n\nEXPAND_DEFAULT_VAR_RECURSIVE=$NO_SUCH_VAR:-$EXPAND_TWO_VARS:-default\n\nEXPAND_DEFAULT_VAR_DEFAULT=$NO_SUCH_VAR:-$NO_SUCH_VAR:-default\n\nEXPAND_DEFAULT_WITH_SPECIAL_CHARACTERS=$UNDEFINED_ENV_KEY:-/default/path\n\nEXPAND_VAR_IN_BRACKETS=${THE_ANSWER}\n\nEXPAND_TWO_VARS_IN_BRACKETS=${QUOTED_SINGLE}!==${QUOTED_DOUBLE}\n\nEXPAND_RECURSIVE_VAR_IN_BRACKETS=${EXPAND_TWO_VARS_IN_BRACKETS}\n\nEXPAND_DEFAULT_IN_BRACKETS_TRUE=${NO_SUCH_VAR:-default}\n\nEXPAND_DEFAULT_IN_BRACKETS_FALSE=${THE_ANSWER:-default}\n\nEXPAND_DEFAULT_VAR_IN_BRACKETS=${NO_SUCH_VAR:-${THE_ANSWER:-default}}\n\nEXPAND_DEFAULT_VAR_IN_BRACKETS_RECURSIVE=${NO_SUCH_VAR:-${EXPAND_TWO_VARS:-default}}\n\nEXPAND_DEFAULT_VAR_IN_BRACKETS_DEFAULT=${NO_SUCH_VAR:-${NO_SUCH_VAR:-default}}\n\nEXPAND_DEFAULT_IN_BRACKETS_WITH_SPECIAL_CHARACTERS=${UNDEFINED_ENV_KEY:-/default/path}\n\nEXPAND_ESCAPED=\\$THE_ANSWER\n\nEXPAND_WITH_DIFFERENT_STYLES=${QUOTED_SINGLE}!==$QUOTED_DOUBLE"
  let result = parse(expand_content)

  // Test basic expansion
  inspect(result.get("EXPAND_VAR"), content="Some(\"42\")")
  inspect(
    result.get("EXPAND_TWO_VARS"),
    content="Some(\"single quoted!==double quoted\")",
  )
  inspect(
    result.get("EXPAND_RECURSIVE"),
    content="Some(\"single quoted!==double quoted\")",
  )

  // Test default values
  inspect(result.get("EXPAND_DEFAULT_TRUE"), content="Some(\"default\")")
  inspect(result.get("EXPAND_DEFAULT_FALSE"), content="Some(\"42\")")
  inspect(result.get("EXPAND_DEFAULT_VAR"), content="Some(\"42\")")
  inspect(
    result.get("EXPAND_DEFAULT_VAR_RECURSIVE"),
    content="Some(\"single quoted!==double quoted\")",
  )
  inspect(result.get("EXPAND_DEFAULT_VAR_DEFAULT"), content="Some(\"default\")")

  // Test bracket syntax
  inspect(result.get("EXPAND_VAR_IN_BRACKETS"), content="Some(\"42\")")
  inspect(
    result.get("EXPAND_TWO_VARS_IN_BRACKETS"),
    content="Some(\"single quoted!==double quoted\")",
  )
  inspect(
    result.get("EXPAND_RECURSIVE_VAR_IN_BRACKETS"),
    content="Some(\"single quoted!==double quoted\")",
  )

  // Test bracket defaults
  inspect(
    result.get("EXPAND_DEFAULT_IN_BRACKETS_TRUE"),
    content="Some(\"default\")",
  )
  inspect(
    result.get("EXPAND_DEFAULT_IN_BRACKETS_FALSE"),
    content="Some(\"42\")",
  )
  inspect(result.get("EXPAND_DEFAULT_VAR_IN_BRACKETS"), content="Some(\"42\")")
  inspect(
    result.get("EXPAND_DEFAULT_VAR_IN_BRACKETS_RECURSIVE"),
    content="Some(\"single quoted!==double quoted\")",
  )
  inspect(
    result.get("EXPAND_DEFAULT_VAR_IN_BRACKETS_DEFAULT"),
    content="Some(\"default\")",
  )

  // Test escaped variables - this should be literal backslash + $THE_ANSWER according to reference
  inspect(result.get("EXPAND_ESCAPED"), content="Some(\"$THE_ANSWER\")")

  // Test mixed styles
  inspect(
    result.get("EXPAND_WITH_DIFFERENT_STYLES"),
    content="Some(\"single quoted!==double quoted\")",
  )
}
