///| MoonBit Dotenv Library Demo
fn main {
  println("MoonBit Dotenv Library Demo")
  println("==========================")

  // Example 1: Basic parsing
  let env_content = "GREETING=hello world\nNAME=MoonBit\nPORT=3000"
  let parsed = @dotenv.parse(env_content)
  println("\n1. Parsed environment variables:")
  for entry in parsed {
    let (key, value) = entry
    println("   \{key} = \{value}")
  }

  // Example 2: Variable expansion
  let expansion_content =
    #|APP_NAME=MoonBit Demo
    #|VERSION=2.0.0
    #|APP_TITLE=$APP_NAME v$VERSION
    #|DATABASE_URL=${DB_URL:-sqlite://./default.db}
    #|LOG_LEVEL=${LOG_LEVEL:-${DEFAULT_LOG:-info}}
    #|ESCAPED=\$VERSION
    #|
  let expanded = @dotenv.parse(expansion_content)
  println("\n2. Variable expansion results:")
  for entry in expanded {
    let (key, value) = entry
    println("   \{key} = \{value}")
  }

  // Example 3: Stringify back to .env format
  let stringified = @dotenv.stringify(parsed)
  println("\n3. Stringified back to .env format:")
  println(stringified)

  // Example 4: Load from string with options
  let options = @dotenv.LoadOptions::with_export()
  let loaded = @dotenv.load_from_string(env_content, options~)
  println("\n4. Loaded with options (export_vars=true):")
  for entry in loaded {
    let (key, value) = entry
    println("   \{key} = \{value}")
  }

  // Example 5: Multiline and complex quoting
  let multiline_content =
    #|# Multiline value in single quotes
    #|SSH_KEY='
    #|-----BEGIN RSA PRIVATE KEY-----
    #|example key content...
    #|-----END RSA PRIVATE KEY-----
    #|'
    #|
    #|# Double quoted with escape sequences
    #|LOG_MSG="Line 1\nLine 2\nLine 3"
    #|
    #|# JSON in single quotes (preserves structure)  
    #|CONFIG='{"host": "localhost", "port": 5432}'
    #|
  let multiline_parsed = @dotenv.parse(multiline_content)
  println("\n5. Multiline and complex quoting:")
  for entry in multiline_parsed {
    let (key, value) = entry
    println("   \{key} = \{value}")
  }
  println("\n✨ Demo completed successfully!")
}
