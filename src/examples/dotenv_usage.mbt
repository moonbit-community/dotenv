///| Dotenv API Usage Examples
///
/// This file demonstrates how to use the dotenv package with the same API
/// as Deno's std/dotenv library.

///|
/// Basic parsing example
fn example_parse() -> Unit {
  // Example 1: Basic parsing - matches Deno API exactly
  let env = @dotenv.parse("GREETING=hello world")
  println("Parsed env: \{env}")

  // Example 2: Complex parsing with quotes and variables
  let complex_env = @dotenv.parse(
    "BASIC=basic\nQUOTED='single quoted'\nDOUBLE=\"double quoted\"\nEMPTY=\n# Comment line\nVAR=\\${BASIC}_extended",
  )
  println("Complex env: \{complex_env}")
}

///|
/// Stringify example
fn example_stringify() -> Unit {
  let env_map = Map::new()
  env_map["GREETING"] = "hello world"
  env_map["PORT"] = "3000"
  env_map["DEBUG"] = "false"
  let dotenv_string = @dotenv.stringify(env_map)
  println("Stringified: \{dotenv_string}")
}

///|
/// Synchronous loading example (mock implementation)
fn example_load_sync() -> Unit {
  // Example 1: Basic load with defaults
  let conf1 = @dotenv.load_sync()
  println("Default load: \{conf1}")

  // Example 2: Load specific file
  let options = @dotenv.LoadOptions::with_path(".env.test")
  let conf2 = @dotenv.load_sync(options~)
  println("Test env load: \{conf2}")

  // Example 3: Load with export enabled
  let export_options = @dotenv.LoadOptions::with_export()
  let conf3 = @dotenv.load_sync(options=export_options)
  println("Export enabled load: \{conf3}")
}

///|
/// Asynchronous loading example
async fn example_load_async() -> Unit noraise {
  // Example 1: Async load with defaults
  let conf1 = @dotenv.load()
  println("Async default load: \{conf1}")

  // Example 2: Async load with custom options
  let options = @dotenv.LoadOptions::with_path_and_export(".env.development")
  let conf2 = @dotenv.load(options~)
  println("Async custom load: \{conf2}")
}

///|
/// Compatibility layer examples
fn example_compat_api() -> Unit {
  // Using the compatibility layer that matches Deno API exactly

  // Parse - matches Deno's parse function
  let env = @dotenv.parse_compat("GREETING=hello world")
  println("Compat parse: \{env}")

  // Stringify - matches Deno's stringify function
  let map = Map::new()
  map["TEST"] = "value"
  let result = @dotenv.stringify_compat(map)
  println("Compat stringify: \{result}")

  // LoadSync - matches Deno's loadSync function
  let options = @dotenv.load_options_compat(
    env_path=Some(".env"),
    export_vars=false,
  )
  let conf = @dotenv.load_sync_compat(options~)
  println("Compat load_sync: \{conf}")
}

///|
/// File operations example using fileops integration
async fn example_file_operations() -> Unit noraise {
  // Check if file exists
  let exists = @dotenv.file_exists_async(".env")
  println("File exists: \{exists}")

  // Read and parse a file
  let conf = @dotenv.parse_file_async(".env")
  println("File parsed: \{conf}")

  // Write environment variables to file
  let env_vars = Map::new()
  env_vars["NEW_VAR"] = "new_value"
  env_vars["ANOTHER_VAR"] = "another_value"
  try {
    @dotenv.write_file_async(".env.new", env_vars)
    println("File written successfully")
  } catch {
    err => println("Error writing file: \{err}")
  }

  // Safe write with backup
  try {
    @dotenv.write_file_safe_async(
      ".env.production",
      env_vars,
      backup_suffix=".bak",
    )
    println("File safely written with backup")
  } catch {
    err => println("Error in safe write: \{err}")
  }
}

///|
/// Demo function showing all features
pub fn demo_all_features() -> Unit {
  println("=== Dotenv API Demo ===")
  println("\n1. Parse Examples:")
  example_parse()
  println("\n2. Stringify Examples:")
  example_stringify()
  println("\n3. Synchronous Load Examples:")
  example_load_sync()
  println("\n4. Compatibility API Examples:")
  example_compat_api()
  println("\n5. Auto-load Example:")
  @dotenv.auto_load()
}

///|
/// Async demo function
pub async fn demo_async_features() -> Unit noraise {
  println("\n=== Async Dotenv Features ===")
  println("\n1. Async Load Examples:")
  example_load_async()
  println("\n2. File Operations Examples:")
  example_file_operations()
}
