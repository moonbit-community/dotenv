///| Comprehensive tests for dotenv parsing based on Deno std library test data

///| Test basic .env functionality using test data
test "parse .env.test file content" {
  let env_content = "BASIC=basic\n\nAFTER_EMPTY=empty\n#COMMENT=not-parsed\nEMPTY_VALUE=\nQUOTED_SINGLE='single quoted'\nQUOTED_DOUBLE=\"double quoted\"\nEMPTY_SINGLE=''\nEMPTY_DOUBLE=\"\"\n\nMULTILINE1=\"hello\\nworld\"\nMULTILINE2=\"hello\\r\\nworld\"\nJSON='{\"foo\": \"bar\"}'\nWHITESPACE='    whitespace   '\nWHITESPACE_DOUBLE=\"    whitespace   \"\nMULTILINE_SINGLE_QUOTE1='hello\\nworld'\nMULTILINE_SINGLE_QUOTE2='hello\\r\\nworld'\nEQUALS='equ==als'\nTHE_ANSWER=42\n\nVAR_WITH_SPACE = 'var with space'\nVAR_WITH_ENDING_WHITESPACE\t=value\nV4R_W1TH_NUM8ER5='var with numbers'\n1INVALID=var starting with a number\n\n  INDENTED_VAR='indented var'\n  INDENTED_VALUE=  indented value\n\tTAB_INDENTED_VAR='indented var'\n\tTAB_INDENTED_VALUE=\tindented value\n\nPRIVATE_KEY_SINGLE_QUOTED='\n-----BEGIN RSA PRIVATE KEY-----\n...\nHkVN9...\n...\n-----END DSA PRIVATE KEY-----\n'\n\nPRIVATE_KEY_DOUBLE_QUOTED=\"\n-----BEGIN RSA PRIVATE KEY-----\n...\nHkVN9...\n...\n-----END DSA PRIVATE KEY-----\n\"\n\nexport EXPORT_IS_IGNORED='export is ignored'"

  let result = parse(env_content)
  
  // Should parse 26 keys (1INVALID is ignored)
  inspect(result.size(), content="26")
  
  // Basic parsing
  inspect(result.get("BASIC"), content="Some(\"basic\")")
  inspect(result.get("AFTER_EMPTY"), content="Some(\"empty\")")
  inspect(result.get("#COMMENT"), content="None") // Comments should be ignored
  inspect(result.get("EMPTY_VALUE"), content="Some(\"\")")
  
  // Quoted values
  inspect(result.get("QUOTED_SINGLE"), content="Some(\"single quoted\")")
  inspect(result.get("QUOTED_DOUBLE"), content="Some(\"double quoted\")")
  inspect(result.get("EMPTY_SINGLE"), content="Some(\"\")")
  inspect(result.get("EMPTY_DOUBLE"), content="Some(\"\")")
  
  // Multiline values
  inspect(result.get("MULTILINE1"), content="Some(\"hello\\nworld\")")
  inspect(result.get("MULTILINE2"), content="Some(\"hello\\r\\nworld\")")
  
  // JSON and special characters
  inspect(result.get("JSON"), content="Some(\"{\\\"foo\\\": \\\"bar\\\"}\")")
  inspect(result.get("WHITESPACE"), content="Some(\"    whitespace   \")")
  inspect(result.get("WHITESPACE_DOUBLE"), content="Some(\"    whitespace   \")")
  
  // Single quotes preserve literal backslashes
  inspect(result.get("MULTILINE_SINGLE_QUOTE1"), content="Some(\"hello\\\\nworld\")")
  inspect(result.get("MULTILINE_SINGLE_QUOTE2"), content="Some(\"hello\\\\r\\\\nworld\")")
  
  // Special characters
  inspect(result.get("EQUALS"), content="Some(\"equ==als\")")
  inspect(result.get("THE_ANSWER"), content="Some(\"42\")")
  
  // Whitespace handling
  inspect(result.get("VAR_WITH_SPACE"), content="Some(\"var with space\")")
  inspect(result.get("VAR_WITH_ENDING_WHITESPACE"), content="Some(\"value\")")
  inspect(result.get("V4R_W1TH_NUM8ER5"), content="Some(\"var with numbers\")")
  
  // Invalid keys should be ignored
  inspect(result.get("1INVALID"), content="None")
  
  // Indented variables
  inspect(result.get("INDENTED_VAR"), content="Some(\"indented var\")")
  inspect(result.get("INDENTED_VALUE"), content="Some(\"indented value\")")
  inspect(result.get("TAB_INDENTED_VAR"), content="Some(\"indented var\")")
  inspect(result.get("TAB_INDENTED_VALUE"), content="Some(\"indented value\")")
  
  // Multiline private keys
  inspect(result.get("PRIVATE_KEY_SINGLE_QUOTED"), content="Some(\"\\n-----BEGIN RSA PRIVATE KEY-----\\n...\\nHkVN9...\\n...\\n-----END DSA PRIVATE KEY-----\\n\")")
  inspect(result.get("PRIVATE_KEY_DOUBLE_QUOTED"), content="Some(\"\\n-----BEGIN RSA PRIVATE KEY-----\\n...\\nHkVN9...\\n...\\n-----END DSA PRIVATE KEY-----\\n\")")
  
  // Export prefix should be ignored
  inspect(result.get("EXPORT_IS_IGNORED"), content="Some(\"export is ignored\")")
}

///| Test comments handling
test "parse .env.comments file content" {
  let env_content = "# This is a comment\nFOO=bar # This is an inline comment\nGREETING= \"hello world\" # hello world\nSPECIAL_CHARACTERS_UNQUOTED=123 #Some text !@# [] \nSPECIAL_CHARACTERS_UNQUOTED_NO_SPACES=123#Some text !@# []"

  let result = parse(env_content)
  
  inspect(result.get("FOO"), content="Some(\"bar\")")
  inspect(result.get("GREETING"), content="Some(\"hello world\")")
  inspect(result.get("SPECIAL_CHARACTERS_UNQUOTED"), content="Some(\"123\")")
  inspect(result.get("SPECIAL_CHARACTERS_UNQUOTED_NO_SPACES"), content="Some(\"123\")")
}

///| Test variable expansion
test "parse .env.expand.test file content" {
  let env_content = "THE_ANSWER=42\n\nQUOTED_SINGLE='single quoted'\n\nQUOTED_DOUBLE=\"double quoted\"\n\nEXPAND_VAR=$THE_ANSWER\n\nEXPAND_TWO_VARS=$QUOTED_SINGLE!==$QUOTED_DOUBLE\n\nEXPAND_RECURSIVE=$EXPAND_TWO_VARS\n\nEXPAND_DEFAULT_TRUE=$NO_SUCH_VAR:-default\n\nEXPAND_DEFAULT_FALSE=$THE_ANSWER:-default\n\nEXPAND_DEFAULT_VAR=$NO_SUCH_VAR:-$THE_ANSWER:-default\n\nEXPAND_DEFAULT_VAR_RECURSIVE=$NO_SUCH_VAR:-$EXPAND_TWO_VARS:-default\n\nEXPAND_DEFAULT_VAR_DEFAULT=$NO_SUCH_VAR:-$NO_SUCH_VAR:-default\n\nEXPAND_DEFAULT_WITH_SPECIAL_CHARACTERS=$UNDEFINED_ENV_KEY:-/default/path\n\nEXPAND_VAR_IN_BRACKETS=${THE_ANSWER}\n\nEXPAND_TWO_VARS_IN_BRACKETS=${QUOTED_SINGLE}!==${QUOTED_DOUBLE}\n\nEXPAND_RECURSIVE_VAR_IN_BRACKETS=${EXPAND_TWO_VARS_IN_BRACKETS}\n\nEXPAND_DEFAULT_IN_BRACKETS_TRUE=${NO_SUCH_VAR:-default}\n\nEXPAND_DEFAULT_IN_BRACKETS_FALSE=${THE_ANSWER:-default}\n\nEXPAND_DEFAULT_VAR_IN_BRACKETS=${NO_SUCH_VAR:-${THE_ANSWER:-default}}\n\nEXPAND_DEFAULT_VAR_IN_BRACKETS_RECURSIVE=${NO_SUCH_VAR:-${EXPAND_TWO_VARS:-default}}\n\nEXPAND_DEFAULT_VAR_IN_BRACKETS_DEFAULT=${NO_SUCH_VAR:-${NO_SUCH_VAR:-default}}\n\nEXPAND_DEFAULT_IN_BRACKETS_WITH_SPECIAL_CHARACTERS=${UNDEFINED_ENV_KEY:-/default/path}\n\nEXPAND_ESCAPED=\\$THE_ANSWER\n\nEXPAND_WITH_DIFFERENT_STYLES=${QUOTED_SINGLE}!==$QUOTED_DOUBLE"

  let result = parse(env_content)
  
  // Basic expansion
  inspect(result.get("EXPAND_VAR"), content="Some(\"42\")")
  inspect(result.get("EXPAND_TWO_VARS"), content="Some(\"single quoted!==double quoted\")")
  inspect(result.get("EXPAND_RECURSIVE"), content="Some(\"single quoted!==double quoted\")")
  
  // Default values
  inspect(result.get("EXPAND_DEFAULT_TRUE"), content="Some(\"default\")")
  inspect(result.get("EXPAND_DEFAULT_FALSE"), content="Some(\"42\")")
  inspect(result.get("EXPAND_DEFAULT_VAR"), content="Some(\"42\")")
  inspect(result.get("EXPAND_DEFAULT_VAR_RECURSIVE"), content="Some(\"single quoted!==double quoted\")")
  inspect(result.get("EXPAND_DEFAULT_VAR_DEFAULT"), content="Some(\"default\")")
  inspect(result.get("EXPAND_DEFAULT_WITH_SPECIAL_CHARACTERS"), content="Some(\"/default/path\")")
  
  // Bracket expansion
  inspect(result.get("EXPAND_VAR_IN_BRACKETS"), content="Some(\"42\")")
  inspect(result.get("EXPAND_TWO_VARS_IN_BRACKETS"), content="Some(\"single quoted!==double quoted\")")
  inspect(result.get("EXPAND_RECURSIVE_VAR_IN_BRACKETS"), content="Some(\"single quoted!==double quoted\")")
  inspect(result.get("EXPAND_DEFAULT_IN_BRACKETS_TRUE"), content="Some(\"default\")")
  inspect(result.get("EXPAND_DEFAULT_IN_BRACKETS_FALSE"), content="Some(\"42\")")
  inspect(result.get("EXPAND_DEFAULT_VAR_IN_BRACKETS"), content="Some(\"42\")")
  inspect(result.get("EXPAND_DEFAULT_VAR_IN_BRACKETS_RECURSIVE"), content="Some(\"single quoted!==double quoted\")")
  inspect(result.get("EXPAND_DEFAULT_VAR_IN_BRACKETS_DEFAULT"), content="Some(\"default\")")
  inspect(result.get("EXPAND_DEFAULT_IN_BRACKETS_WITH_SPECIAL_CHARACTERS"), content="Some(\"/default/path\")")
  
  // Escaped variables (note: the backslash should be removed)
  inspect(result.get("EXPAND_ESCAPED"), content="Some(\"$THE_ANSWER\")")
  
  // Mixed styles
  inspect(result.get("EXPAND_WITH_DIFFERENT_STYLES"), content="Some(\"single quoted!==double quoted\")")
}

///| Test single expansion
test "parse .env.single.expand file content" {
  let env_content = "EXPECT_EMPTY=$EMPTY"
  let result = parse(env_content)
  inspect(result.get("EXPECT_EMPTY"), content="Some(\"\")")
}