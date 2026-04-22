///| Load module for dotenv - provides real file I/O operations
///
/// This module contains the actual file loading functionality that uses
/// the async file system operations from fileops package.

// parse_file_sync is defined in mod.mbt to avoid duplication

///|
/// Parse file asynchronously with real file system operations
///
/// @param filepath The path to the .env file
/// @returns Promise of the parsed environment variables as a Map
pub async fn parse_file_async(filepath : String) -> Map[String, String] noraise {
  try {
    // Use the real async file reading from fileops package
    let content = @fileops.read_env_file_content(filepath)
    parse(content)
  } catch {
    _ => Map::new() // Return empty map if file doesn't exist
  }
}

///|
/// Write environment variables to file asynchronously
///
/// @param filepath The path to the .env file
/// @param env_vars The environment variables to write
/// @param permission Optional file permission (defaults to 0o644)
pub async fn write_file_async(
  filepath : String,
  env_vars : Map[String, String],
  permission? : Int = 0o644,
) -> Unit {
  let content = stringify(env_vars)
  @fileops.write_env_file_raw(filepath, content, permission~)
}

///|
/// Write environment variables to file safely with backup
///
/// @param filepath The path to the .env file
/// @param env_vars The environment variables to write
/// @param backup_suffix Optional backup suffix (defaults to ".backup")
pub async fn write_file_safe_async(
  filepath : String,
  env_vars : Map[String, String],
  backup_suffix? : String = ".backup",
) -> Unit {
  let content = stringify(env_vars)
  @fileops.write_env_file_safe(filepath, content, backup_suffix~)
}

///|
/// Check if a .env file exists
///
/// @param filepath The path to the .env file
/// @returns True if the file exists, false otherwise
pub async fn file_exists_async(filepath : String) -> Bool noraise {
  @fileops.file_exists(filepath)
}

///|
/// Export the mock implementation for compatibility
pub fn parse_file_sync_mock(filepath : String) -> Map[String, String] {
  // This matches the implementation from mod.mbt
  match filepath {
    ".env" => {
      let sample_content = "GREETING=hello world\nPORT=3000\nDEBUG=false"
      parse(sample_content)
    }
    ".env.test" => {
      let sample_content = "BASIC=basic\nEMPTY_VALUE=\nQUOTED_SINGLE='single quoted'"
      parse(sample_content)
    }
    ".env.development" | ".env.dev" => {
      let sample_content = "NODE_ENV=development\nPORT=3000\nDEBUG=true"
      parse(sample_content)
    }
    ".env.production" | ".env.prod" => {
      let sample_content = "NODE_ENV=production\nPORT=8000\nDEBUG=false"
      parse(sample_content)
    }
    ".env.local" => {
      let sample_content = "LOCAL_VAR=local_value\nOVERRIDE=true"
      parse(sample_content)
    }
    _ => Map::new() // File not found - return empty map
  }
}
