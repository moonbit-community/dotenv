///| MoonBit Dotenv Library Example

///|

///| This file demonstrates key features of the MoonBit dotenv module:

///| - Basic parsing and stringification

///| - Variable expansion with different syntaxes

///| - Multiline values and complex quoting

///| - Load options and configurations

///| Example function showing basic dotenv parsing
pub fn basic_example() -> Unit {
  println("=== Basic Dotenv Example ===")
  let env_content =
    #|# Database configuration
    #|DB_HOST=localhost
    #|DB_PORT=5432
    #|DB_NAME=myapp
    #|DB_USER=admin
    #|DB_PASSWORD=super secret password
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

///| Example function showing variable expansion features
pub fn expansion_example() -> Unit {
  println("\n=== Variable Expansion Example ===")
  let env_content =
    #|# Base configuration
    #|APP_NAME=MoonBit Dotenv Demo
    #|VERSION=1.0.0
    #|ENV=development
    #|
    #|# Variable expansion with $VAR syntax
    #|APP_TITLE=$APP_NAME v$VERSION
    #|
    #|# Variable expansion with ${VAR} syntax
    #|FULL_APP_INFO=${APP_NAME} version ${VERSION} (${ENV})
    #|
    #|# Default values with ${VAR:-default} syntax
    #|DATABASE_URL=${DATABASE_URL:-sqlite://./default.db}
    #|PORT=${PORT:-8080}
    #|
    #|# Nested default values
    #|LOG_LEVEL=${LOG_LEVEL:-${DEFAULT_LOG_LEVEL:-info}}
    #|
    #|# Escaped variables (should not expand)
    #|ESCAPED_VAR=\$VERSION
    #|
  let parsed = @dotenv.parse(env_content)
  println("Variable expansion results:")
  for entry in parsed {
    let (key, value) = entry
    println("  \{key} = \{value}")
  }
}

///| Example showing multiline values and complex quoting
pub fn multiline_example() -> Unit {
  println("\n=== Multiline and Complex Quoting Example ===")
  let env_content =
    #|# Single quoted multiline (preserves literal content)
    #|SSH_PRIVATE_KEY='
    #|-----BEGIN RSA PRIVATE KEY-----
    #|MIIEpAIBAAKCAQEA7h6+JH1...
    #|...example key content...
    #|-----END RSA PRIVATE KEY-----
    #|'
    #|
    #|# Double quoted multiline (expands escape sequences)
    #|LOG_MESSAGE="Line 1\nLine 2\nLine 3"
    #|
    #|# JSON configuration in single quotes
    #|JSON_CONFIG='{"database": {"host": "localhost", "port": 5432}}'
    #|
  let parsed = @dotenv.parse(env_content)
  println("Multiline and complex quoting results:")
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
pub fn load_example() -> Unit {
  println("\n=== Load From String Example ===")
  let env_content = "DATABASE_URL=postgres://user:pass@localhost/db\nREDIS_URL=redis://localhost:6379"

  // Load with default options
  let config1 = @dotenv.load_from_string(env_content)
  println("Loaded with default options:")
  for entry in config1 {
    let (key, value) = entry
    println("  \{key} = \{value}")
  }

  // Load with export option
  let options = @dotenv.LoadOptions::with_export()
  let config2 = @dotenv.load_from_string(env_content, options~)
  println("\nLoaded with export option:")
  for entry in config2 {
    let (key, value) = entry
    println("  \{key} = \{value}")
  }
}

///| Main function to run all examples
fn main {
  println("MoonBit Dotenv Library Examples")
  println("==============================")
  basic_example()
  expansion_example()
  multiline_example()
  stringify_example()
  round_trip_example()
  load_example()
  println("\n✨ All examples completed successfully!")
}
