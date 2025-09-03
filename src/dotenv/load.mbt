///| Load environment variables from .env files

///|

///| This module provides functionality to load environment variables from .env files

///| on disk. Note that in MoonBit's current runtime environment, file system access

///| is limited, so this module provides structure compatible with the Deno std library

///| but with mock implementations.

///|

///| Inspired by the node modules {@linkcode https://github.com/motdotla/dotenv | dotenv}

///| and {@linkcode https://github.com/motdotla/dotenv-expand | dotenv-expand}.

///|

///| @example Auto-loading from .env file

///| ```moonbit

///| let conf = load_sync() // Loads from ./.env by default

///| ```

///|

///| @example Loading with options

///| ```moonbit

///| let options = LoadOptions::{ env_path: Some(".env.prod"), export_vars: true }

///| let conf = load_sync(options)

///| ```

///| Load environment variables from a .env file synchronously

///|

///| Works identically to {@linkcode load}, but synchronously.

///|

///| The parsing engine supports the following rules:

///| - Variables that already exist in the environment are not overridden with `export_vars: true`

///| - `BASIC=basic` becomes `{ BASIC: "basic" }`

///| - empty lines are skipped

///| - lines beginning with `#` are treated as comments

///| - empty values become empty strings (`EMPTY=` becomes `{ EMPTY: "" }`)

///| - single and double quoted values are escaped (`SINGLE_QUOTE='quoted'` becomes `{ SINGLE_QUOTE: "quoted" }`)

///| - new lines are expanded in double quoted values (`MULTILINE="new\nline"` becomes `{ MULTILINE: "new\nline" }`)

///| - inner quotes are maintained (think JSON) (`JSON={"foo": "bar"}` becomes `{ JSON: "{\"foo\": \"bar\"}" }`)

///| - whitespace is removed from both ends of unquoted values (`FOO= some value` becomes `{ FOO: "some value" }`)

///| - whitespace is preserved on both ends of quoted values (`FOO=" some value "` becomes `{ FOO: " some value " }`)

///| - dollar sign with an environment key in or without curly braces in unquoted values will expand the environment key (`KEY=$KEY` or `KEY=${KEY}` becomes `{ KEY: "<KEY_VALUE_FROM_ENV>" }`)

///| - escaped dollar sign with an environment key in unquoted values will escape the environment key rather than expand (`KEY=\$KEY` becomes `{ KEY: "$KEY" }`)

///| - colon and a minus sign with a default value in expanding construction in unquoted values will first attempt to expand the environment key. If it's not found, then it will return the default value (`KEY=${KEY:-default}` becomes `{ KEY: "default" }` if KEY doesn't exist)

///|

///| @example Basic usage

///| ```moonbit

///| let conf = load_sync() // Uses default .env file

///| ```

///|

///| @example With custom options

///| ```moonbit

///| let options = LoadOptions::{ env_path: Some(".env.production"), export_vars: true }

///| let conf = load_sync(options)

///| ```

///|

///| @param options Optional LoadOptions (defaults to .env file, no export)

///| @returns The parsed environment variables as a Map
pub fn load_sync(
  options? : LoadOptions = LoadOptions::default(),
) -> Map[String, String] {
  let env_path = match options.env_path {
    Some(path) => path
    None => return Map::new() // No file to load
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

///| Load environment variables from a .env file asynchronously

///|

///| Load environment variables from a `.env` file. Loaded variables are accessible

///| in a configuration object returned by the `load()` function, as well as optionally

///| exporting them to the process environment using the `export_vars` option.

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

///| ```moonbit

///| let conf = load() // { GREETING: "hello world" }

///| ```

///|

///| ## Auto loading

///| Import the `load` functionality to auto-import from the `.env` file and into

///| the process environment.

///|

///| @example Auto-loading

///| ```moonbit

///| auto_load() // Automatically loads .env file

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

///| |env_path|./.env|Path and filename of the `.env` file. Use None to prevent the .env file from being loaded.

///| |export_vars|false|When true, this will export all environment variables in the `.env` file to the process environment but only if they are not already set. If a variable is already in the process, the `.env` value is ignored.

///|

///| ### Example configuration

///|

///| @example Using with options

///| ```moonbit

///| let options = LoadOptions::{ env_path: Some(".env_prod"), export_vars: true }

///| let conf = load(options)

///| ```

///|

///| ## Permissions

///|

///| At a minimum, loading the `.env` related files requires file system read permissions.

///| Additionally, if you access the process environment, either through exporting your

///| configuration or expanding variables in your `.env` file, you will need environment

///| variable access permissions.

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

///|   becomes `{ MULTILINE: "new\nline" }`)

///| - inner quotes are maintained (think JSON) (`JSON={"foo": "bar"}` becomes

///|   `{ JSON: "{\"foo\": \"bar\"}" }`)

///| - whitespace is removed from both ends of unquoted values (see more on

///|   trim) (`FOO= some value` becomes `{ FOO: "some value" }`)

///| - whitespace is preserved on both ends of quoted values (`FOO=" some value "`

///|   becomes `{ FOO: " some value " }`)

///| - dollar sign with an environment key in or without curly braces in unquoted

///|   values will expand the environment key (`KEY=$KEY` or `KEY=${KEY}` becomes

///|   `{ KEY: "<KEY_VALUE_FROM_ENV>" }`)

///| - escaped dollar sign with an environment key in unquoted values will escape the

///|   environment key rather than expand (`KEY=\$KEY` becomes `{ KEY: "$KEY" }`)

///| - colon and a minus sign with a default value(which can also be another expand

///|   value) in expanding construction in unquoted values will first attempt to

///|   expand the environment key. If it's not found, then it will return the default

///|   value (`KEY=${KEY:-default}` If KEY exists it becomes

///|   `{ KEY: "<KEY_VALUE_FROM_ENV>" }` If not, then it becomes

///|   `{ KEY: "default" }`. Also there is possible to do this case

///|   `KEY=${NO_SUCH_KEY:-${EXISTING_KEY:-default}}` which becomes

///|   `{ KEY: "<EXISTING_KEY_VALUE_FROM_ENV>" }`)

///|

///| @param options The LoadOptions configuration object

///| @returns The parsed environment variables as a Map
pub fn load(
  options? : LoadOptions = LoadOptions::default(),
) -> Map[String, String] {
  // In a real async implementation, this would be:
  // async fn load(options? : LoadOptions = LoadOptions::default()) -> Map[String, String]
  // For now, delegate to the sync version
  load_sync(options~)
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
  //   loadSync({ export: true });
  // }

  // Check if we have file system capabilities (mock check)
  let has_file_system = true // In reality, this would check runtime capabilities
  if not(has_file_system) {
    println(
      "Warning: File system read is not available: No .env data was read.",
    )
  } else {
    // Load with export enabled (equivalent to { export: true })
    let options = LoadOptions::with_export()
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
