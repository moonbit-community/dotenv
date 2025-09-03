///| MoonBit Dotenv Example

///|

///| This file demonstrates how to use the MoonBit dotenv module to parse

///| and stringify environment variables in .env file format.

///| Example function showing basic dotenv parsing
pub fn parse_example() -> Unit {
  println("=== Dotenv Parse Example ===")
  
  let env_content = 
    #|# Database configuration
    #|DB_HOST=localhost
    #|DB_PORT=5432
    #|DB_NAME=myapp
    #|DB_USER=admin
    #|DB_PASSWORD=super secret password
    #|
    #|# API configuration  
    #|API_KEY=abc123-def456-ghi789
    #|API_TIMEOUT=30
    #|
    #|# Feature flags
    #|DEBUG=true
    #|VERBOSE_LOGGING=false
    #|
  
  let parsed = @dotenv.parse(env_content)
  
  println("Parsed \{parsed.size()} environment variables:")
  for entry in parsed {
    let (key, value) = entry
    println("  \{key} = \{value}")
  }
}

///| Example function showing dotenv stringification
pub fn stringify_example() -> Unit {
  println("\n=== Dotenv Stringify Example ===")
  let env : Map[String, String] = Map::new()
  env["APP_NAME"] = "MoonBit Dotenv Demo"
  env["VERSION"] = "1.0.0"
  env["PORT"] = "8080"
  env["SECRET_KEY"] = "my-secret-key-123"
  env["DEBUG"] = "true"
  env["MULTILINE_CONFIG"] = "line1\nline2\nline3"
  let stringified = @dotenv.stringify(env)
  println("Stringified environment variables:")
  println(stringified)
}

///| Example function showing round-trip conversion
pub fn round_trip_example() -> Unit {
  println("\n=== Round Trip Example ===")
  let original = "GREETING=hello world\nNAME=MoonBit\nVERSION=0.1.0"
  println("Original .env content:")
  println(original)
  let parsed = @dotenv.parse(original)
  let back_to_string = @dotenv.stringify(parsed)
  println("\nAfter parse and stringify:")
  println(back_to_string)

  // Verify they contain the same key-value pairs
  let reparsed = @dotenv.parse(back_to_string)
  println("\nVerification:")
  for entry in parsed {
    let (key, value) = entry
    match reparsed.get(key) {
      Some(reparsed_value) =>
        if value == reparsed_value {
          println("  ✓ \{key}: \{value}")
        } else {
          println("  ✗ \{key}: \{value} != \{reparsed_value}")
        }
      None => println("  ✗ \{key}: missing in reparsed")
    }
  }
}

///| Example using the load_from_string function
pub fn load_from_string_example() -> Unit {
  println("\n=== Load From String Example ===")
  let env_content = "DATABASE_URL=postgres://user:pass@localhost/db\nREDIS_URL=redis://localhost:6379"

  // Load with default options
  let config1 = @dotenv.load_from_string(env_content)
  println("Loaded with default options:")
  for entry in config1 {
    let (key, value) = entry
    println("  \{key} = \{value}")
  }

  // Load with export option (simulated)
  let options = @dotenv.LoadOptions::{ export_to_env: true }
  let config2 = @dotenv.load_from_string(env_content, options~)
  println("\nLoaded with export option:")
  for entry in config2 {
    let (key, value) = entry
    println("  \{key} = \{value}")
  }
}

///| Run the demo function from the dotenv module
pub fn demo_example() -> Unit {
  println("\n=== Demo Function Example ===")
  let demo_result = @dotenv.demo()
  println(demo_result)
}

///| Main function to run all examples
fn main {
  println("MoonBit Dotenv Library Examples")
  println("==============================")
  parse_example()
  stringify_example()
  round_trip_example()
  load_from_string_example()
  demo_example()
  println("\n✨ All examples completed successfully!")
}