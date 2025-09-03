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
  let options = LoadOptions::{ export_to_env: true }
  let result = load_from_string(content, options~)
  inspect(result.size(), content="2")
  inspect(result.get("DEBUG"), content="Some(\"true\")")
  inspect(result.get("LOG_LEVEL"), content="Some(\"info\")")
}

///|
test "LoadOptions default" {
  let options = LoadOptions::default()
  inspect(options.export_to_env, content="false")
}

///|
test "demo function" {
  let result = demo()

  // Check that the demo function returns a non-empty string
  inspect(result.length() > 0, content="true")
  inspect(result.contains("Parsed"), content="true")
  inspect(result.contains("environment variables"), content="true")
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
