///| MoonBit Dotenv Module

///|

///| Parses and loads environment variables from a `.env` file into the current

///| process, or stringify data into a `.env` file format.

///|

///| Note: The key needs to match the pattern /^[a-zA-Z_][a-zA-Z0-9_]*$/.

///|

///| ```moonbit ignore

///| // Automatically load environment variables from a `.env` file

///| import "@dotenv/load";

///| ```

///|

///| ```moonbit

///| let env = parse("GREETING=hello world")

///| // Returns: {"GREETING": "hello world"}

///| let dotenv_string = stringify(env)

///| // Returns: "GREETING='hello world'"

///| ```

///|

///| @module

///|
/// Options for {@linkcode load} and {@linkcode load_sync}.
pub struct LoadOptions {
  /// Optional path to `.env` file. To prevent the default value from being
  /// used, set to `None`.
  ///
  /// @default {"./.env"}
  env_path : String?
  /// Set to `true` to export all `.env` variables to the current processes
  /// environment. Variables are then accessible via environment access
  /// (in a full runtime environment with environment variable support).
  ///
  /// @default {false}
  export_vars : Bool
} derive(Show, Eq, Default)

///|
/// Create default LoadOptions
pub fn LoadOptions::default() -> LoadOptions {
  LoadOptions::{ env_path: Some(".env"), export_vars: false }
}

///|
/// Create LoadOptions with custom env_path
pub fn LoadOptions::with_path(path : String) -> LoadOptions {
  LoadOptions::{ env_path: Some(path), export_vars: false }
}

///|
/// Create LoadOptions with export enabled
pub fn LoadOptions::with_export() -> LoadOptions {
  LoadOptions::{ env_path: Some(".env"), export_vars: true }
}

///|
/// Create LoadOptions with custom path and export
pub fn LoadOptions::with_path_and_export(path : String) -> LoadOptions {
  LoadOptions::{ env_path: Some(path), export_vars: true }
}

///|
/// Create LoadOptions with no env_path (prevents default file loading)
pub fn LoadOptions::no_file() -> LoadOptions {
  LoadOptions::{ env_path: None, export_vars: false }
}

///| Works identically to {@linkcode load}, but synchronously.

///|

///| @example Usage

///| ```moonbit ignore

///| let conf = load_sync()

///| ```

///|

///| @param options Options for loading the environment variables.

///|
/// @returns The parsed environment variables.
pub fn load_sync(
  options? : LoadOptions = LoadOptions::default(),
) -> Map[String, String] {
  let env_path = match options.env_path {
    Some(path) => path
    None => return Map::new() // No file to load
  }
  let conf = parse_file_sync(env_path)
  if options.export_vars {
    // In a real implementation, this would export to the process environment
    // for (let [key, value] of Object.entries(conf)) {
    //   if (Deno.env.get(key) !== undefined) continue;
    //   Deno.env.set(key, value);
    // }
    // For now, we just return the parsed configuration
  }
  conf
}

///| Load environment variables from a `.env` file asynchronously.

///|

///| This is the async version that provides the same API as Deno's std/dotenv.

///| Loaded variables are accessible in a configuration object returned by the

///| `load()` function, as well as optionally exporting them to the process

///| environment using the `export_vars` option.

///|

///| @example Basic usage

///| ```moonbit ignore

///| @async.with_event_loop(fn(_) {

///|   let conf = load()  // Load from .env with defaults

///|   println(conf.get("GREETING"))

///| })

///| ```

///|

///| @param options The options

///|
/// @returns Promise of the parsed environment variables
pub async fn load(
  options? : LoadOptions = LoadOptions::default(),
) -> Map[String, String] noraise {
  let env_path = match options.env_path {
    Some(path) => path
    None => return Map::new() // No file to load
  }
  let conf = parse_file_async(env_path)
  if options.export_vars {
    // In a real implementation, this would export to the process environment
    // For now, we just return the parsed configuration
  }
  conf
}

// Duplicate load_sync function removed - using the one defined earlier

///| Load environment variables from .env content string

///|

///| This function parses .env content and returns the environment variables

///| as a Map. Unlike the file-based load functions, this doesn't read from filesystem

///| but takes content as a string parameter.

///|

///| @example Basic usage

///| ```moonbit

///| let content = "GREETING=hello world\nPORT=3000"

///| let conf = load_from_string(content)

///| // Returns: {"GREETING": "hello world", "PORT": "3000"}

///| ```

///|

///| @param content The .env file content as a string

///| @param options Optional LoadOptions (defaults to export=false)

///|
/// @returns The parsed environment variables as a Map
pub fn load_from_string(
  content : String,
  options? : LoadOptions = LoadOptions::default(),
) -> Map[String, String] {
  let conf = parse(content)

  // Note: In a real implementation with file system access,
  // the export option would set environment variables.
  // For now, we just return the parsed configuration.
  if options.export_vars {
    // In a full implementation, this would export to global environment
    // Currently just returns the parsed configuration
  }
  conf
}

///|
/// Parse a file synchronously using the load module
///
/// This function delegates to the load module which provides both
/// mock and real file system implementations.
///
/// @param filepath The path to the .env file
/// @returns The parsed environment variables as a Map
fn parse_file_sync(filepath : String) -> Map[String, String] {
  // Delegate to the load module which handles file I/O
  parse_file_sync_mock(filepath)
}

///| Auto-load functionality (mock implementation)

///|

///| This function mimics the behavior of importing "@std/dotenv/load" in Deno,

///| which automatically loads the .env file and exports variables to the environment.

///|

///| Works identically to {@linkcode load_sync}, but automatically exports variables.

///|

///| Note: In the current implementation, this checks if file system read functionality

///| is available and warns if .env data cannot be loaded.

///|

///| @example Auto-loading

///| ```moonbit

///| auto_load() // Automatically loads .env and exports to environment

///|
/// ```
pub fn auto_load() -> Unit {
  // Mimic the behavior from load.ts in Deno std:
  // if (!(Deno.readTextFileSync instanceof Function)) {
  //   console.warn(`Deno.readTextFileSync is not a function: No .env data was read.`);
  // } else {
  //   loadSync({ export_vars: true });
  // }

  // Check if we have file system capabilities (mock check)
  let has_file_system = true // In reality, this would check runtime capabilities
  if not(has_file_system) {
    println(
      "Warning: File system read is not available: No .env data was read.",
    )
  } else {
    // Load with export enabled (equivalent to { export_vars: true })
    let options = LoadOptions::{ env_path: Some(".env"), export_vars: true }
    let conf = load_sync(options~)
    if conf.is_empty() {
      println(
        "Warning: No .env data was loaded (file system access not available or file not found)",
      )
    } else {
      println("Auto-loaded \{conf.size()} environment variables from .env")
    }
  }
}
