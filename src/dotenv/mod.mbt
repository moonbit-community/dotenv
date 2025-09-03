///| MoonBit Dotenv Module

///|

///| Parses and stringifies environment variables in .env file format.

///| This module provides functionality to parse .env file content into a Map

///| and stringify a Map back into .env file format.

///|

///| Supports advanced features including:

///| - Variable expansion with $VAR and ${VAR} syntax

///| - Default values with ${VAR:-default} syntax

///| - Escaped variables with \$VAR syntax

///| - Recursive variable expansion

///| - Single and double quoted values

///| - Multi-line values and comments

///|

///| Note: The key needs to match the pattern /^[a-zA-Z_][a-zA-Z0-9_]*$/.

///|

///| @example Basic usage

///| ```moonbit

///| let env_content = "GREETING=hello world\nNAME=MoonBit"

///| let env = parse(env_content)

///| // Returns: {"GREETING": "hello world", "NAME": "MoonBit"}

///|

///| let back_to_string = stringify(env)

///| // Returns .env formatted string

///| ```

///|

///| @example Variable expansion

///| ```moonbit

///| let env_content = "NAME=MoonBit\nGREETING=Hello $NAME\nDEFAULT_PORT=${PORT:-8080}"

///| let env = parse(env_content)

///| // Returns: {"NAME": "MoonBit", "GREETING": "Hello MoonBit", "DEFAULT_PORT": "8080"}

///| ```

///|

///| @module

///| Load options for parsing .env content and file-based loading
pub struct LoadOptions {
  /// Optional path to .env file. If None, defaults to "./.env"
  env_path : String?
  /// Whether to export all .env variables to a global environment
  /// Note: MoonBit doesn't have a global process environment like Deno,
  /// so this is for API compatibility and future extensions
  export_vars : Bool
} derive(Show, Eq, Default)

///| Create default LoadOptions
pub fn LoadOptions::default() -> LoadOptions {
  LoadOptions::{ env_path: Some(".env"), export_vars: false }
}

///| Create LoadOptions with custom env_path
pub fn LoadOptions::with_path(path : String) -> LoadOptions {
  LoadOptions::{ env_path: Some(path), export_vars: false }
}

///| Create LoadOptions with export enabled
pub fn LoadOptions::with_export() -> LoadOptions {
  LoadOptions::{ env_path: Some(".env"), export_vars: true }
}

///| Create LoadOptions with custom path and export
pub fn LoadOptions::with_path_and_export(path : String) -> LoadOptions {
  LoadOptions::{ env_path: Some(path), export_vars: true }
}

///| Create LoadOptions with no env_path
pub fn LoadOptions::no_file() -> LoadOptions {
  LoadOptions::{ env_path: None, export_vars: false }
}

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

///| @param options Optional LoadOptions (defaults to export_vars=false)

///| @returns The parsed environment variables as a Map
pub fn load_from_string(
  content : String,
  options? : LoadOptions = LoadOptions::default(),
) -> Map[String, String] {
  let conf = parse(content)

  // Note: In a real implementation with file system access,
  // the export_vars option would set environment variables.
  // For now, we just return the parsed configuration.
  if options.export_vars {
    // In a full implementation, this would export to global environment
    // Currently just returns the parsed configuration
  }
  conf
}
