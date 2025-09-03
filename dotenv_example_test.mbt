///| Tests for the dotenv examples
test "parse_example runs without error" {
  // Just verify the function runs without throwing exceptions
  parse_example()
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
test "load_from_string_example runs without error" {
  load_from_string_example()
  inspect(true, content="true")
}

///|
test "demo_example runs without error" {
  demo_example()
  inspect(true, content="true")
}
