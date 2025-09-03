# MoonBit Dotenv

A MoonBit library for parsing and stringifying `.env` files, migrated from the Deno standard library.

## Features

- 🔧 **Parse .env files** - Convert .env file content into a Map
- 📝 **Stringify Maps** - Convert Maps back to .env file format
- 🚀 **Variable expansion** - Support for `$VAR` and `${VAR}` syntax
- ⚙️ **Default values** - Support for `${VAR:-default}` syntax
- 🛡️ **Escaped variables** - Support for `\$VAR` to prevent expansion
- 🔄 **Recursive expansion** - Variables can reference other variables
- 🎯 **Type safe** - Full MoonBit type safety
- 🧪 **Well tested** - Comprehensive test suite
- 📚 **Well documented** - Clear API documentation and examples

## Installation

Add this package to your MoonBit project:

```bash
moon add username/dotenv
```

Then import it in your `moon.pkg.json`:

```json
{
  "import": ["username/dotenv/dotenv"]
}
```

## Quick Start

```moonbit
// Parse .env content
let env_content = "GREETING=hello world\nPORT=3000"
let env = @dotenv.parse(env_content)

// Access values
match env.get("GREETING") {
  Some(value) => println("Greeting: \{value}")
  None => println("Greeting not found")
}

// Stringify back to .env format
let stringified = @dotenv.stringify(env)
println(stringified)
```

## API Reference

### `parse(content: String) -> Map[String, String]`

Parse .env file content into a Map.

**Example:**
```moonbit
let content = "DB_HOST=localhost\nDB_PORT=5432"
let env = @dotenv.parse(content)
```

### `stringify(env: Map[String, String]) -> String`

Convert a Map to .env file format.

**Example:**
```moonbit
let env : Map[String, String] = Map::new()
env["API_KEY"] = "secret123"
env["DEBUG"] = "true"
let output = @dotenv.stringify(env)
// Output: "API_KEY=secret123\nDEBUG=true"
```

### `load_from_string(content: String, options?: LoadOptions) -> Map[String, String]`

Load environment variables from .env content with options.

**Example:**
```moonbit
let content = "NODE_ENV=production"
let options = @dotenv.LoadOptions::{ export_to_env: true }
let env = @dotenv.load_from_string(content, options~)
```

## Supported .env Format

The parser supports the standard .env file format with variable expansion:

```bash
# Comments start with #
BASIC=basic

# Empty values
EMPTY=

# Quoted values
SINGLE_QUOTED='single quoted value'
DOUBLE_QUOTED="double quoted value"

# Multiline values (double quoted)
MULTILINE="line1\nline2\nline3"

# Values with special characters
SPECIAL_CHARS='value with spaces and !@#'

# Variable expansion (only in unquoted values)
NAME=MoonBit
GREETING=Hello $NAME
FULL_GREETING=${GREETING}, welcome!

# Default values
PORT=${PORT:-8080}
DATABASE_URL=${DB_URL:-sqlite://./default.db}

# Nested defaults
LOG_LEVEL=${LOG_LEVEL:-${DEFAULT_LOG_LEVEL:-info}}

# Escaped variables (prevent expansion)
ESCAPED_VAR=\$VERSION

# Export syntax (ignored)
export EXPORTED_VAR=value

# Whitespace handling
  INDENTED_VAR=value
SPACED_VALUE = spaced value
```

## Parsing Rules

- Empty lines and lines starting with `#` are ignored
- Keys must match the pattern `/^[a-zA-Z_][a-zA-Z0-9_]*$/`
- Values can be unquoted, single-quoted, or double-quoted
- Double-quoted values support escape sequences (`\n`, `\r`, `\t`)
- Single-quoted values are literal (no escape sequences or variable expansion)
- **Variable expansion** only occurs in unquoted values:
  - `$VAR` expands to the value of `VAR`
  - `${VAR}` expands to the value of `VAR`
  - `${VAR:-default}` expands to `VAR` if defined, otherwise `default`
  - `\$VAR` prevents expansion (escaped)
- Recursive expansion is supported (variables can reference other variables)
- Whitespace around keys and unquoted values is trimmed
- The `export` prefix is ignored

## Stringification Rules

- Values with special characters are automatically quoted
- Values with spaces use single quotes
- Values with newlines or single quotes use double quotes with escaping
- Numeric-like values remain unquoted
- Keys starting with `#` are ignored (treated as comments)

## Examples

### Basic Usage

```moonbit
let env_content = 
  #|# Database configuration
  #|DB_HOST=localhost
  #|DB_PORT=5432
  #|DB_NAME=myapp
  #|

let parsed = @dotenv.parse(env_content)
println("Database host: \{parsed.get("DB_HOST").or("unknown")}")
```

### Round-trip Conversion

```moonbit
let original = "GREETING=hello world\nNAME=MoonBit"
let parsed = @dotenv.parse(original)
let back_to_string = @dotenv.stringify(parsed)
// Values are preserved through the round trip
```

### Variable Expansion

```moonbit
let env_content = 
  #|# Base configuration
  #|APP_NAME=MoonBit Demo
  #|VERSION=1.0.0
  #|ENV=development
  #|
  #|# Variable expansion
  #|APP_TITLE=$APP_NAME v$VERSION
  #|FULL_INFO=${APP_NAME} version ${VERSION} (${ENV})
  #|
  #|# Default values
  #|DATABASE_URL=${DB_URL:-sqlite://./default.db}
  #|PORT=${PORT:-8080}
  #|
  #|# Nested defaults
  #|LOG_LEVEL=${LOG_LEVEL:-${DEFAULT_LOG_LEVEL:-info}}
  #|
  #|# Escaped variables
  #|ESCAPED=\$VERSION
  #|

let parsed = @dotenv.parse(env_content)
// Results in:
// APP_TITLE = "MoonBit Demo v1.0.0"
// FULL_INFO = "MoonBit Demo version 1.0.0 (development)"
// DATABASE_URL = "sqlite://./default.db" (using default)
// PORT = "8080" (using default)
// LOG_LEVEL = "info" (using nested default)
// ESCAPED = "$VERSION" (literal, not expanded)
```

### Error Handling

```moonbit
let env_content = "1INVALID=value\nVALID_KEY=value"
let parsed = @dotenv.parse(env_content)
// Invalid keys are ignored with a warning
// Only valid keys are included in the result
```

## Running the Examples

Run the included examples:

```bash
moon run dotenv_example.mbt
```

## Running Tests

```bash
moon test
```

## Project Structure

```
src/
├── dotenv/
│   ├── parse.mbt          # Parsing logic
│   ├── parse_test.mbt     # Parse tests
│   ├── stringify.mbt      # Stringification logic
│   ├── stringify_test.mbt # Stringify tests
│   ├── mod.mbt           # Main module interface
│   ├── mod_test.mbt      # Module tests
│   ├── moon.pkg.json     # Package configuration
│   └── testdata/         # Test data files
│       ├── .env.test
│       ├── .env.comments
│       └── .env.simple
├── dotenv_example.mbt     # Usage examples
└── dotenv_example_test.mbt # Example tests
```

## Differences from Deno std/dotenv

This MoonBit implementation has some differences from the original Deno version:

1. **No file system access** - Functions take content strings instead of file paths
2. **No process environment** - The `export` option is for API compatibility (no global process environment)
3. **Variable expansion** - Full variable expansion is implemented including `$VAR`, `${VAR}`, `${VAR:-default}`, and escaped variables
4. **Different error handling** - Uses MoonBit's type system instead of exceptions

## Implemented Features from Deno std

✅ **Complete**: Variable expansion with `$VAR` and `${VAR}` syntax  
✅ **Complete**: Default values with `${VAR:-default}` syntax  
✅ **Complete**: Escaped variables with `\$VAR` syntax  
✅ **Complete**: Recursive variable expansion  
✅ **Complete**: Single and double quoted values  
✅ **Complete**: Multi-line values and escape sequences  
✅ **Complete**: Comments and empty lines  
✅ **Complete**: Export prefix handling  
✅ **Complete**: Comprehensive parsing and stringification

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for your changes
4. Ensure all tests pass
5. Submit a pull request

## License

Apache-2.0 License

## Credits

Migrated from the [Deno Standard Library](https://github.com/denoland/std) dotenv module.