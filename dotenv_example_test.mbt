///| Tests for the dotenv examples - verifying functionality works correctly
test "basic_example executes successfully" {
  // Verify basic example runs without errors
  basic_example()
  inspect(true, content="true")
}

///|
test "variable_expansion_example executes successfully" {
  // Verify variable expansion example runs without errors
  variable_expansion_example()
  inspect(true, content="true")
}

///|
test "quoting_and_multiline_example executes successfully" {
  // Verify quoting example runs without errors
  quoting_and_multiline_example()
  inspect(true, content="true")
}

///|
test "stringify_example executes successfully" {
  // Verify stringify example runs without errors
  stringify_example()
  inspect(true, content="true")
}

///|
test "load_configuration_example executes successfully" {
  // Verify load configuration example runs without errors
  load_configuration_example()
  inspect(true, content="true")
}

///|
test "advanced_features_example executes successfully" {
  // Verify advanced features example runs without errors
  advanced_features_example()
  inspect(true, content="true")
}

///| Test that the examples demonstrate correct dotenv functionality
test "examples demonstrate correct functionality" {
  // Test basic parsing as shown in examples
  let basic_content = "APP_NAME=MoonBit Dotenv Demo\nVERSION=1.0.0\nDEBUG=true"
  let basic_result = @dotenv.parse(basic_content)
  inspect(basic_result.get("APP_NAME"), content="Some(\"MoonBit Dotenv Demo\")")
  inspect(basic_result.get("VERSION"), content="Some(\"1.0.0\")")
  inspect(basic_result.get("DEBUG"), content="Some(\"true\")")

  // Test variable expansion as shown in examples
  let expansion_content = "APP_NAME=MoonBit\nVERSION=1.0.0\nAPP_TITLE=$APP_NAME v$VERSION"
  let expansion_result = @dotenv.parse(expansion_content)
  inspect(expansion_result.get("APP_TITLE"), content="Some(\"MoonBit v1.0.0\")")

  // Test default values as shown in examples
  let default_content = "DATABASE_URL=${DATABASE_URL:-sqlite://./app.db}"
  let default_result = @dotenv.parse(default_content)
  inspect(
    default_result.get("DATABASE_URL"),
    content="Some(\"sqlite://./app.db\")",
  )

  // Test stringification round-trip as shown in examples
  let env : Map[String, String] = Map::new()
  env["APP_NAME"] = "Test App"
  env["VERSION"] = "1.0.0"
  let stringified = @dotenv.stringify(env)
  let reparsed = @dotenv.parse(stringified)
  inspect(reparsed.get("APP_NAME"), content="Some(\"Test App\")")
  inspect(reparsed.get("VERSION"), content="Some(\"1.0.0\")")

  // Test LoadOptions as shown in examples
  let sample_content = "APP_ENV=development\nSERVER_PORT=3000"
  let config = @dotenv.load_from_string(sample_content)
  inspect(config.get("APP_ENV"), content="Some(\"development\")")
  inspect(config.get("SERVER_PORT"), content="Some(\"3000\")")
}

///| Test that different LoadOptions work correctly
test "load_options_work_correctly" {
  let sample_content = "TEST_VAR=test_value"

  // Test default options
  let default_opts = @dotenv.LoadOptions::default()
  let config1 = @dotenv.load_from_string(sample_content, default_opts~)
  inspect(config1.get("TEST_VAR"), content="Some(\"test_value\")")

  // Test with export option
  let export_opts = @dotenv.LoadOptions::with_export()
  let config2 = @dotenv.load_from_string(sample_content, export_opts~)
  inspect(config2.get("TEST_VAR"), content="Some(\"test_value\")")
  inspect(export_opts.export_vars, content="true")

  // Test with custom path
  let path_opts = @dotenv.LoadOptions::with_path(".env.custom")
  inspect(path_opts.env_path, content="Some(\".env.custom\")")
  inspect(path_opts.export_vars, content="false")

  // Test with both path and export
  let both_opts = @dotenv.LoadOptions::with_path_and_export(".env.local")
  inspect(both_opts.env_path, content="Some(\".env.local\")")
  inspect(both_opts.export_vars, content="true")
}

///| Test advanced expansion scenarios from examples
test "advanced_expansion_scenarios_work" {
  let complex_content = "BASE_URL=https://api.example.com\nAPI_VERSION=v2\nAPI_ENDPOINT=${BASE_URL}/${API_VERSION}\nFULL_ENDPOINT=${API_ENDPOINT}/data"
  let result = @dotenv.parse(complex_content)
  inspect(
    result.get("API_ENDPOINT"),
    content="Some(\"https://api.example.com/v2\")",
  )
  inspect(
    result.get("FULL_ENDPOINT"),
    content="Some(\"https://api.example.com/v2/data\")",
  )

  // Test nested defaults
  let nested_defaults = "CACHE_TTL=${CACHE_TTL:-${DEFAULT_CACHE_TTL:-3600}}"
  let nested_result = @dotenv.parse(nested_defaults)
  inspect(nested_result.get("CACHE_TTL"), content="Some(\"3600\")")

  // Test escaped variables
  let escaped_content = "ENVIRONMENT=staging\nESCAPED_EXAMPLE=This has \\$ENVIRONMENT (literal) and ${ENVIRONMENT} (expanded)"
  let escaped_result = @dotenv.parse(escaped_content)
  inspect(
    escaped_result.get("ESCAPED_EXAMPLE"),
    content="Some(\"This has $ENVIRONMENT (literal) and staging (expanded)\")",
  )
}
