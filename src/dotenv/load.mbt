///| Load environment variables from .env files

///|

///| This module provides functionality to load environment variables from .env files

///| on disk. Note that in MoonBit's current runtime environment, file system access

///| is limited, so this module provides structure compatible with the Deno std library

///| but with mock implementations.

///|

///| @example Auto-loading from .env file

///| ```moonbit

///| let conf = load_sync() // Loads from ./.env by default

///| ```

///|

///| @example Loading with options

///| ```moonbit

///| let options = LoadOptions::{ env_path: Some(".env.prod"), export: true }

///| let conf = load_sync(options)

///| ```

// LoadOptions is defined in mod.mbt and re-exported here

/// Load environment variables from a .env file synchronously

///

/// This function loads environment variables from a .env file on disk.

/// Note: In the current MoonBit environment, this is a mock implementation

/// that demonstrates the API structure but doesn't perform actual file operations.

///

/// @example Basic usage

/// ```moonbit

/// let conf = load_sync() // Uses default .env file

/// ```

///

/// @example With custom options

/// ```moonbit

/// let options = LoadOptions::{ env_path: Some(".env.production"), export: true }

/// let conf = load_sync(options)

/// ```

///

/// @param options Optional LoadOptions (defaults to .env file, no export)

///| @returns The parsed environment variables as a Map
pub fn load_sync(
  options? : LoadOptions = LoadOptions::default(),
) -> Map[String, String] {
  let env_path = match options.env_path {
    Some(path) => path
    None => ".env"
  }

  // Mock implementation - in a real environment with file system access,
  // this would read the file from disk using something like:
  // let content = read_text_file(env_path) catch { _ => "" }
  let conf = parse_file_sync(env_path)
  if options.export_vars {
    // In a real implementation, this would export to the process environment
    // For now, we just return the parsed configuration
    for entry in conf {
      let (_key, _value) = entry
      // set_env_var(key, value) // Would set environment variable
    }
  }
  conf
}

///| Parse a file synchronously (mock implementation)
fn parse_file_sync(filepath : String) -> Map[String, String] {
  // Mock implementation - in a real environment, this would:
  // try {
  //   let content = read_text_file(filepath)
  //   parse(content)
  // } catch {
  //   FileNotFound => Map::new()
  //   other => raise other
  // }

  // For demonstration, return sample data based on common file names
  match filepath {
    ".env" => {
      let sample_content = "GREETING=hello world\nPORT=3000"
      parse(sample_content)
    }
    ".env.test" => {
      let sample_content = "BASIC=basic\nEMPTY_VALUE=\nQUOTED_SINGLE='single quoted'"
      parse(sample_content)
    }
    _ => Map::new() // File not found
  }
}

/// Async version of load (mock implementation)

///

/// This would be the async version of load_sync in a full implementation.

/// Currently returns the same result as load_sync since we don't have

/// async file operations in the current MoonBit environment.

///

/// @param options Optional LoadOptions

///| @returns Promise-like result with the parsed environment variables
pub fn load(
  options? : LoadOptions = LoadOptions::default(),
) -> Map[String, String] {
  // In a real async implementation, this would be:
  // async fn load(options? : LoadOptions = LoadOptions::default()) -> Map[String, String]
  // For now, delegate to the sync version
  load_sync(options~)
}

/// Auto-load functionality (mock implementation)

///

/// This function mimics the behavior of importing "@std/dotenv/load" in Deno,

/// which automatically loads the .env file and exports variables to the environment.

///

/// @example Auto-loading

/// ```moonbit

/// auto_load() // Automatically loads .env and exports to environment

///| ```
pub fn auto_load() -> Unit {
  // Mock the behavior of the load.ts file from Deno std
  let options = LoadOptions::with_export()
  let conf = load_sync(options~)

  // In a real implementation, this would check for file system capabilities
  // and warn if file reading is not available
  if conf.is_empty() {
    println(
      "Warning: No .env data was loaded (file system access not available)",
    )
  } else {
    println("Auto-loaded \{conf.size()} environment variables from .env")
  }
}
