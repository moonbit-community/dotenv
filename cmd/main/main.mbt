///| MoonBit Dotenv Library Demo

///|

///| A simple demonstration of the MoonBit dotenv module's core functionality
fn main {
  println("MoonBit Dotenv Library Demo")
  println("==========================")

  // Demo 1: Basic parsing
  let env_content = "GREETING=hello world\nNAME=MoonBit\nPORT=3000"
  let parsed = @dotenv.parse(env_content)
  println("\n1. Basic parsing:")
  for entry in parsed {
    let (key, value) = entry
    println("   \{key} = \{value}")
  }

  // Demo 2: Variable expansion
  let expansion_content =
    #|APP_NAME=MoonBit Demo
    #|VERSION=2.0.0
    #|APP_TITLE=$APP_NAME v$VERSION
    #|DATABASE_URL=${DB_URL:-sqlite://./default.db}
    #|
  let expanded = @dotenv.parse(expansion_content)
  println("\n2. Variable expansion:")
  for entry in expanded {
    let (key, value) = entry
    println("   \{key} = \{value}")
  }

  // Demo 3: Stringify back to .env format
  let stringified = @dotenv.stringify(parsed)
  println("\n3. Stringified .env format:")
  println(stringified)
  println(
    "\n✨ Demo completed! See dotenv_example.mbt for comprehensive examples.",
  )
}
