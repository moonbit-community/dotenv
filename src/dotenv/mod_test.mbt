///| Tests for the main dotenv module
test "load_from_string basic functionality" {
  let content = "GREETING=hello world\nPORT=3000"
  let result = load_from_string(content)
  inspect(result.size(), content="2")
  inspect(result.get("GREETING"), content="Some(\"hello world\")")
  inspect(result.get("PORT"), content="Some(\"3000\")")
}

///|
test "load_from_string with default options" {
  let content = "NAME=MoonBit\nVERSION=1.0"
  let result = load_from_string(content, options=LoadOptions::default())
  inspect(result.size(), content="2")
  inspect(result.get("NAME"), content="Some(\"MoonBit\")")
  inspect(result.get("VERSION"), content="Some(\"1.0\")")
}

///|
test "load_from_string with export option" {
  let content = "DEBUG=true\nLOG_LEVEL=info"
  let options = LoadOptions::with_export()
  let result = load_from_string(content, options~)
  inspect(result.size(), content="2")
  inspect(result.get("DEBUG"), content="Some(\"true\")")
  inspect(result.get("LOG_LEVEL"), content="Some(\"info\")")
}

///|
test "LoadOptions creation methods" {
  let default_options = LoadOptions::default()
  inspect(default_options.export_vars, content="false")
  inspect(default_options.env_path, content="Some(\".env\")")
  let export_options = LoadOptions::with_export()
  inspect(export_options.export_vars, content="true")
  inspect(export_options.env_path, content="Some(\".env\")")
  let custom_path = LoadOptions::with_path("/custom/.env")
  inspect(custom_path.export_vars, content="false")
  inspect(custom_path.env_path, content="Some(\"/custom/.env\")")
  let no_file = LoadOptions::no_file()
  inspect(no_file.export_vars, content="false")
  inspect(no_file.env_path, content="None")
}

///|
test "load_from_string with variable expansion" {
  let content = "BASE_URL=https://api.example.com\nAPI_ENDPOINT=$BASE_URL/v1"
  let result = load_from_string(content)
  inspect(result.get("BASE_URL"), content="Some(\"https://api.example.com\")")
  inspect(
    result.get("API_ENDPOINT"),
    content="Some(\"https://api.example.com/v1\")",
  )
}

///|
test "round trip parsing and stringifying" {
  let original_content = "GREETING=hello world\nNAME=MoonBit\nPORT=3000"

  // Parse the content
  let parsed = parse(original_content)

  // Stringify it back
  let stringified = stringify(parsed)

  // Parse the stringified version
  let reparsed = parse(stringified)

  // Should have the same number of entries
  inspect(parsed.size(), content="3")
  inspect(reparsed.size(), content="3")

  // Values should be preserved
  inspect(reparsed.get("GREETING"), content="Some(\"hello world\")")
  inspect(reparsed.get("NAME"), content="Some(\"MoonBit\")")
  inspect(reparsed.get("PORT"), content="Some(\"3000\")")
}
