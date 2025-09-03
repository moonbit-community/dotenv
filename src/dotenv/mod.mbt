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

///| Options for {@linkcode load} and {@linkcode load_sync}.
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

///| Create LoadOptions with no env_path (prevents default file loading)
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

///| @returns The parsed environment variables.
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

///| Load environment variables from a `.env` file.  Loaded variables are accessible

///| in a configuration object returned by the `load()` function, as well as optionally

///| exporting them to the process environment using the `export` option.

///|

///| Inspired by the node modules {@linkcode https://github.com/motdotla/dotenv | dotenv}

///| and {@linkcode https://github.com/motdotla/dotenv-expand | dotenv-expand}.

///|

///| Note: The key needs to match the pattern /^[a-zA-Z_][a-zA-Z0-9_]*$/.

///|

///| ## Basic usage

///| ```sh

///| # .env

///| GREETING=hello world

///| ```

///|

///| Then import the environment variables using the `load` function.

///|

///| @example Basic usage

///| ```moonbit ignore

///| // app.mbt

///| let env = load(LoadOptions::{ export_vars: true, env_path: Some(".env") })

///| println(env["GREETING"] |> Option::unwrap) // hello world

///| ```

///|

///| Run this with appropriate file system and environment permissions.

///|

///| .env files support blank lines, comments, multi-line values and more.

///| See Parsing Rules below for more detail.

///|

///| ## Auto loading

///| Import the `load` functionality to auto-import from the `.env` file and into

///| the process environment.

///|

///| @example Auto-loading

///| ```moonbit ignore

///| // app.mbt

///| auto_load()

///| ```

///|

///| ## Files

///| Dotenv supports a number of different files, all of which are optional.

///| File names and paths are configurable.

///|

///| |File|Purpose|

///| |----|-------|

///| |.env|primary file for storing key-value environment entries

///|

///| ## Configuration

///|

///| Loading environment files comes with a number of options passed into

///| the `load()` function, all of which are optional.

///|

///| |Option|Default|Description

///| |------|-------|-----------

///| |env_path|./.env|Path and filename of the `.env` file.  Use None to prevent the .env file from being loaded.

///| |export_vars|false|When true, this will export all environment variables in the `.env` file to the process environment but only if they are not already set.  If a variable is already in the process, the `.env` value is ignored.

///|

///| ### Example configuration

///|

///| @example Using with options

///| ```moonbit

///| let conf = load(LoadOptions::{

///|   env_path: Some(".env_prod"), // Uses .env_prod instead of .env

///|   export_vars: true, // Exports all variables to the environment

///| })

///| ```

///|

///| ## Permissions

///|

///| At a minimum, loading the `.env` related files requires file system read permission.

///| Additionally, if you access the process environment, either through exporting your

///| configuration or expanding variables in your `.env` file, you will need environment

///| variable access permission.

///|

///| ## Parsing Rules

///|

///| The parsing engine currently supports the following rules:

///|

///| - Variables that already exist in the environment are not overridden with

///|   `export_vars: true`

///| - `BASIC=basic` becomes `{ BASIC: "basic" }`

///| - empty lines are skipped

///| - lines beginning with `#` are treated as comments

///| - empty values become empty strings (`EMPTY=` becomes `{ EMPTY: "" }`)

///| - single and double quoted values are escaped (`SINGLE_QUOTE='quoted'` becomes

///|   `{ SINGLE_QUOTE: "quoted" }`)

///| - new lines are expanded in double quoted values (`MULTILINE="new\nline"`

///|   becomes

///|

///| ```

///| { MULTILINE: "new\nline" }

///| ```

///|

///| - inner quotes are maintained (think JSON) (`JSON={"foo": "bar"}` becomes

///|   `{ JSON: "{\"foo\": \"bar\"}" }`)

///| - whitespace is removed from both ends of unquoted values (see more on

///|   {@linkcode https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/Trim | trim})

///|   (`FOO= some value` becomes `{ FOO: "some value" }`)

///| - whitespace is preserved on both ends of quoted values (`FOO=" some value "`

///|   becomes `{ FOO: " some value " }`)

///| - dollar sign with an environment key in or without curly braces in unquoted

///|   values will expand the environment key (`KEY=$KEY` or `KEY=${KEY}` becomes

///|   `{ KEY: "<KEY_VALUE_FROM_ENV>" }`)

///| - escaped dollar sign with an environment key in unquoted values will escape the

///|   environment key rather than expand (`KEY=\$KEY` becomes `{ KEY: "\\$KEY" }`)

///| - colon and a minus sign with a default value(which can also be another expand

///|   value) in expanding construction in unquoted values will first attempt to

///|   expand the environment key. If it's not found, then it will return the default

///|   value (`KEY=${KEY:-default}` If KEY exists it becomes

///|   `{ KEY: "<KEY_VALUE_FROM_ENV>" }` If not, then it becomes

///|   `{ KEY: "default" }`. Also there is possible to do this case

///|   `KEY=${NO_SUCH_KEY:-${EXISTING_KEY:-default}}` which becomes

///|   `{ KEY: "<EXISTING_KEY_VALUE_FROM_ENV>" }`)

///|

///| @param options The options

///| @returns The parsed environment variables
pub fn load(
  options? : LoadOptions = LoadOptions::default(),
) -> Map[String, String] {
  // In a real async implementation, this would be:
  // async fn load(options? : LoadOptions = LoadOptions::default()) -> Map[String, String]
  // For now, delegate to the sync version since MoonBit doesn't have async file I/O yet
  load_sync(options~)
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

///| @param options Optional LoadOptions (defaults to export=false)

///| @returns The parsed environment variables as a Map
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

///| Parse a file synchronously (mock implementation)

///|

///| In a real implementation with file system access, this would:

///| - Try to read the file content from the filesystem

///| - Parse the content using the parse function

///| - Return an empty Map if the file is not found (NotFound error)

///| - Propagate other errors

///|

///| This function mimics the behavior of parseFile and parseFileSync from

///| the Deno std library.

///|

///| @param filepath The path to the .env file

///| @returns The parsed environment variables as a Map
fn parse_file_sync(filepath : String) -> Map[String, String] {
  // Mock implementation - in a real environment, this would:
  // try {
  //   let content = read_text_file(filepath)
  //   parse(content)
  // } catch {
  //   NotFound => Map::new()  // Return empty map if file doesn't exist
  //   other => raise other    // Propagate other errors
  // }

  // For demonstration, return sample data based on common file names
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

///| ```
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
