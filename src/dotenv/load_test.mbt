///| Test cases for the load module

///|

///| These tests verify the file-based loading functionality of the dotenv module.

///| Note: Since file system access is limited in the current MoonBit environment,

///| these tests work with the mock implementations.
test "load_sync handles default options" {
  let result = load_sync()

  // With mock implementation, should return sample data
  inspect(result.get("GREETING"), content="Some(\"hello world\")")
  inspect(result.get("PORT"), content="Some(\"3000\")")
  inspect(result.size() >= 2, content="true")
}

///|
test "load_sync handles custom env path" {
  let options = LoadOptions::with_path(".env.test")
  let result = load_sync(options~)

  // Should return test data based on mock implementation
  inspect(result.get("BASIC"), content="Some(\"basic\")")
  inspect(result.get("EMPTY_VALUE"), content="Some(\"\")")
  inspect(result.get("QUOTED_SINGLE"), content="Some(\"single quoted\")")
}

///|
test "load_sync handles non-existent files" {
  let options = LoadOptions::with_path("nonexistent.env")
  let result = load_sync(options~)

  // Should return empty map for non-existent files
  inspect(result.is_empty(), content="true")
  inspect(result.size(), content="0")
}

///|
test "load_sync handles export option" {
  let options = LoadOptions::with_export()
  let result = load_sync(options~)

  // Should still return the parsed variables even with export_vars=true
  inspect(result.get("GREETING"), content="Some(\"hello world\")")
  inspect(result.get("PORT"), content="Some(\"3000\")")
}

///|
test "load function delegates to load_sync" {
  let result = load()
  let sync_result = load_sync()

  // Should return the same result
  for entry in sync_result {
    let (key, value) = entry
    inspect(result.get(key), content="Some(\"\{value}\")")
  }
  inspect(result.size(), content="\{sync_result.size()}")
}

///|
test "LoadOptions default constructor" {
  let options = LoadOptions::default()
  inspect(options.env_path, content="Some(\".env\")")
  inspect(options.export_vars, content="false")
}

///|
test "LoadOptions with custom values" {
  let options = LoadOptions::with_path_and_export(".env.production")
  inspect(options.env_path, content="Some(\".env.production\")")
  inspect(options.export_vars, content="true")
}

///|
test "LoadOptions with None env_path" {
  let options = LoadOptions::no_file()
  inspect(options.env_path, content="None")
  inspect(options.export_vars, content="false")
}

///|
test "auto_load function runs without error" {
  // auto_load should run without throwing errors
  auto_load()

  // Test passes if no exception is thrown
  inspect(true, content="true")
}

///|
test "load with different file extensions" {
  let result1 = load_sync() // Use default options
  let result2 = load_sync(options=LoadOptions::with_path(".env.test"))
  let result3 = load_sync(options=LoadOptions::with_path(".env.production"))

  // Different files should return different or empty results
  inspect(result1.size() > 0, content="true")
  inspect(result2.size() > 0, content="true")
  inspect(result3.size(), content="3") // .env.production has sample data
}

///|
test "load options are properly used" {
  // Test that None env_path is handled correctly
  let options_none = LoadOptions::no_file()
  let result_none = load_sync(options=options_none)

  // With None env_path, should return empty map (no file to load)
  inspect(result_none.size(), content="0")

  // Compare with default which should have data
  let result_default = load_sync()
  inspect(result_default.size() > 0, content="true")
}
