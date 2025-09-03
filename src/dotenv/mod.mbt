///| MoonBit Dotenv Module

///|

///| Parses and stringifies environment variables in .env file format.

///| This module provides functionality to parse .env file content into a Map

///| and stringify a Map back into .env file format.

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

///| @module

///| Load options for parsing .env content
pub struct LoadOptions {
  /// Whether to export_to_env all .env variables to a global environment
  ///| Note: MoonBit doesn't have a global process environment like Deno,
  ///| so this is for API compatibility and future extensions
  export_to_env : Bool
} derive(Show, Eq)

///| Create default LoadOptions
pub fn LoadOptions::default() -> LoadOptions {
  LoadOptions::{ export_to_env: false }
}

///| Load environment variables from .env content string

///|

///| This function parses .env content and returns the environment variables

///| as a Map. Unlike the Deno version, this doesn't read from filesystem

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

///| @param options Optional LoadOptions (defaults to export_to_env=false)

///| @returns The parsed environment variables as a Map
pub fn load_from_string(
  content : String,
  options? : LoadOptions = LoadOptions::default(),
) -> Map[String, String] {
  let conf = parse(content)

  // Note: In a real implementation with file system access,
  // the export_to_env option would set environment variables.
  // For now, we just return the parsed configuration.
  if options.export_to_env {
    // In a full implementation, this would export to global environment
    // Currently just returns the parsed configuration
  }
  conf
}

///| A simple example function showing how to use the dotenv module

///|

///| @example

///| ```moonbit

///| let demo_result = demo()

///| println(demo_result)

///| ```
pub fn demo() -> String {
  let env_content = "# This is a comment\nGREETING=hello world\nNAME=MoonBit\nPORT=3000\nDEBUG=true\nQUOTED='single quoted value'\nMULTILINE=\"line1\\nline2\""
  let parsed = parse(env_content)
  let stringified = stringify(parsed)
  "Parsed \{parsed.size()} environment variables:\n\{stringified}"
}
