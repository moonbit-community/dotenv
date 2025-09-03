///| Tests for the dotenv examples
test "basic_example runs without error" {
  // Just verify the function runs without throwing exceptions
  basic_example()
  inspect(true, content="true")
}

///|
test "stringify_example runs without error" {
  stringify_example()
  inspect(true, content="true")
}

///|
test "round_trip_example runs without error" {
  round_trip_example()
  inspect(true, content="true")
}

///|
test "load_example runs without error" {
  load_example()
  inspect(true, content="true")
}

///|
test "expansion_example runs without error" {
  expansion_example()
  inspect(true, content="true")
}

///|
test "multiline_example runs without error" {
  multiline_example()
  inspect(true, content="true")
}

///| Test that all examples produce expected output
test "examples produce valid results" {
  // Test that parse examples work
  let env_content = "DB_HOST=localhost\nDB_PORT=5432"
  let parsed = @dotenv.parse(env_content)
  inspect(parsed.get("DB_HOST"), content="Some(\"localhost\")")
  inspect(parsed.get("DB_PORT"), content="Some(\"5432\")")

  // Test variable expansion
  let expansion_content = "APP_NAME=MoonBit\nVERSION=1.0.0\nAPP_TITLE=$APP_NAME v$VERSION"
  let expanded = @dotenv.parse(expansion_content)
  inspect(expanded.get("APP_TITLE"), content="Some(\"MoonBit v1.0.0\")")

  // Test stringification
  let env : Map[String, String] = Map::new()
  env["TEST"] = "value"
  env["QUOTED"] = "hello world"
  let stringified = @dotenv.stringify(env)
  inspect(stringified.contains("TEST=value"), content="true")
  inspect(stringified.contains("QUOTED='hello world'"), content="true")
}
