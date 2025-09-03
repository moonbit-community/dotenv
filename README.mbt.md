# MoonBit Dotenv

A comprehensive MoonBit implementation of dotenv functionality for parsing and handling .env files, migrated from the Deno standard library.

## Features

- **Parse .env file format** - Convert .env content to Map[String, String]
- **Stringify environment variables** - Convert Map back to .env format
- **Comments support** - Lines starting with # are ignored
- **Quoted values** - Single and double quoted strings with escape sequences
- **Multiline strings** - Support for multiline values in double quotes
- **Variable expansion** - Support for $VAR and ${VAR} syntax
- **Default values** - Support for ${VAR:-default} fallback syntax
- **Recursive expansion** - Variables can reference other variables
- **Escaped variables** - Use \$VAR to prevent expansion
- **File-based loading** - Mock implementation for future file system integration
- **Comprehensive test coverage** - Based on Deno std library test suite

## Quick Start

### Basic Parsing

```moonbit
let env_content = "GREETING=hello world\nPORT=3000"
let parsed = @dotenv.parse(env_content)
// Returns: {"GREETING": "hello world", "PORT": "3000"}

let stringified = @dotenv.stringify(parsed)
// Returns .env formatted string
```

### Variable Expansion

```moonbit
let env_content = 
  #|APP_NAME=MoonBit Dotenv
  #|VERSION=1.0.0
  #|APP_TITLE=${APP_NAME} v${VERSION}
  #|DATABASE_URL=${DATABASE_URL:-sqlite://./default.db}
  #|

let parsed = @dotenv.parse(env_content)
// Results in:
// {
//   "APP_NAME": "MoonBit Dotenv",
//   "VERSION": "1.0.0", 
//   "APP_TITLE": "MoonBit Dotenv v1.0.0",
//   "DATABASE_URL": "sqlite://./default.db"
// }
```

### Load from String with Options

```moonbit
let content = "DEBUG=true\nLOG_LEVEL=info"
let options = @dotenv.LoadOptions::with_export()
let config = @dotenv.load_from_string(content, options~)
```

### File-based Loading (Mock Implementation)

```moonbit
// Load default .env file
let config = @dotenv.load_sync()

// Load specific file
let config = @dotenv.load_sync(options=@dotenv.LoadOptions::with_path(".env.production"))

// Auto-load with export
@dotenv.auto_load()
```

## API Reference

### Core Functions

#### `parse(content: String) -> Map[String, String]`

Parse .env file content into a Map of environment variables.

**Features:**
- Supports comments (lines starting with #)
- Handles quoted and unquoted values
- Processes escape sequences in double quotes
- Expands variables using $VAR and ${VAR} syntax
- Supports default values with ${VAR:-default}
- Validates environment variable names

#### `stringify(env: Map[String, String]) -> String`

Convert environment variables Map back to .env file format.

**Features:**
- Automatically quotes values with special characters
- Escapes quotes and newlines appropriately
- Handles multiline values with double quotes
- Skips invalid keys (starting with #)

### Load Functions

#### `load_from_string(content: String, options?: LoadOptions) -> Map[String, String]`

Load environment variables from string content with optional configuration.

#### `load_sync(options?: LoadOptions) -> Map[String, String]`

Load environment variables from file (mock implementation).

#### `load(options?: LoadOptions) -> Map[String, String]`

Async version of load_sync (currently delegates to sync version).

#### `auto_load() -> Unit`

Automatically load .env file and export to environment (mock implementation).

### LoadOptions

```moonbit
pub struct LoadOptions {
  env_path : String?     // Path to .env file
  export_vars : Bool     // Whether to export to environment
}
```

**Constructors:**
- `LoadOptions::default()` - Default options (.env, no export)
- `LoadOptions::with_path(path: String)` - Custom path, no export
- `LoadOptions::with_export()` - Default path with export
- `LoadOptions::with_path_and_export(path: String)` - Custom path with export
- `LoadOptions::no_file()` - No file path, no export

## Supported .env Format

### Basic Variables
```bash
# Comments start with #
BASIC=basic value
EMPTY_VALUE=
```

### Quoted Values
```bash
SINGLE_QUOTED='single quoted value'
DOUBLE_QUOTED="double quoted value"
EMPTY_SINGLE=''
EMPTY_DOUBLE=""
```

### Multiline Values
```bash
MULTILINE="line1\nline2\nline3"
PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
...key content...
-----END RSA PRIVATE KEY-----"
```

### Variable Expansion
```bash
NAME=MoonBit
VERSION=1.0.0
APP_TITLE=$NAME v$VERSION
FULL_INFO=${NAME} version ${VERSION}

# Default values
PORT=${PORT:-8080}
DATABASE_URL=${DATABASE_URL:-sqlite://./default.db}

# Nested defaults
LOG_LEVEL=${LOG_LEVEL:-${DEFAULT_LOG_LEVEL:-info}}

# Escaped variables (no expansion)
ESCAPED=\$NAME
```

### Special Cases
```bash
# Export prefix is ignored
export IGNORED_EXPORT=value

# Whitespace handling
  INDENTED_VAR=value
VAR_WITH_SPACE = value with space

# Equals in values
COMPLEX_VALUE=key=value&other=thing

# Invalid keys are ignored (warning shown)
1INVALID=ignored
```

## Migration from Deno std/dotenv

This implementation is based on the Deno standard library's dotenv module and maintains API compatibility where possible. Key differences:

1. **File system access**: Current implementation provides mock file operations
2. **Environment export**: Simulated rather than actual process environment modification  
3. **Error handling**: Uses MoonBit's error handling patterns
4. **Type system**: Leverages MoonBit's strong typing and pattern matching

## Testing

Run the comprehensive test suite:

```bash
moon test
```

The test suite includes:
- All parsing scenarios from the reference implementation
- Variable expansion edge cases
- Round-trip parse/stringify testing
- Load function testing
- Error handling and invalid input testing

## Examples

See `dotenv_example.mbt` for comprehensive usage examples including:
- Basic parsing and stringification
- Variable expansion demonstrations
- Round-trip conversion
- Load functions usage
- Advanced scenarios

## License

Apache-2.0

## Contributing

This module is migrated from the Deno standard library dotenv module. When contributing, please ensure compatibility with the reference implementation and maintain comprehensive test coverage.