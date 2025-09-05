///| Compatibility layer for Deno std/dotenv API
///
/// This module provides functions that match the exact API of Deno's std/dotenv
/// to ensure maximum compatibility.

///|
/// Options interface compatible with Deno std/dotenv
///
/// This matches the LoadOptions interface from the Deno implementation
pub typealias LoadOptions as LoadOptionsCompat

///|
/// Create LoadOptions with Deno-compatible defaults
pub fn load_options_compat(
  env_path? : String? = Some(".env"),
  export_vars? : Bool = false,
) -> LoadOptionsCompat {
  LoadOptions::{ env_path, export_vars }
}

///|
/// Load environment variables asynchronously - Deno API compatible
///
/// This function signature matches Deno's std/dotenv load function exactly:
/// ```typescript
/// export async function load(options: LoadOptions = {}): Promise<Record<string, string>>
/// ```
///
/// @param options The load options (optional, defaults to reading .env with no export)
/// @returns Promise of the parsed environment variables
pub async fn load_compat(
  options? : LoadOptionsCompat = load_options_compat(),
) -> Map[String, String] noraise {
  load(options~)
}

///|
/// Load environment variables synchronously - Deno API compatible
///
/// This function signature matches Deno's std/dotenv loadSync function exactly:
/// ```typescript
/// export function loadSync(options: LoadOptions = {}): Record<string, string>
/// ```
///
/// @param options The load options (optional, defaults to reading .env with no export)
/// @returns The parsed environment variables
pub fn load_sync_compat(
  options? : LoadOptionsCompat = load_options_compat(),
) -> Map[String, String] {
  load_sync(options~)
}

///|
/// Parse .env content - directly compatible with Deno std/dotenv
///
/// This function matches Deno's parse function signature:
/// ```typescript
/// export function parse(text: string): Record<string, string>
/// ```
///
/// Note: The key needs to match the pattern /^[a-zA-Z_][a-zA-Z0-9_]*$/.
///
/// @example Usage
/// ```moonbit
/// let env = parse_compat("GREETING=hello world")
/// // Returns: {"GREETING": "hello world"}
/// ```
///
/// @param text The text to parse.
/// @returns The parsed object.
pub fn parse_compat(text : String) -> Map[String, String] {
  parse(text)
}

///|
/// Stringify a Map into .env format - directly compatible with Deno std/dotenv
///
/// This function matches Deno's stringify function signature:
/// ```typescript
/// export function stringify(object: Record<string, string>): string
/// ```
///
/// @example Usage
/// ```moonbit
/// let object = Map::new()
/// object["GREETING"] = "hello world"
/// let result = stringify_compat(object)
/// // Returns: "GREETING='hello world'"
/// ```
///
/// @param object Map to be stringified
/// @returns String representation in .env format
pub fn stringify_compat(object : Map[String, String]) -> String {
  stringify(object)
}

///|
/// Auto-load functionality that matches Deno's load.ts behavior
///
/// This mimics the behavior of importing "@std/dotenv/load" in Deno,
/// which automatically loads the .env file and exports variables to the environment.
///
/// @example Auto-loading
/// ```moonbit
/// auto_load_compat() // Automatically loads .env and exports to environment
/// ```
pub fn auto_load_compat() -> Unit {
  auto_load()
}
