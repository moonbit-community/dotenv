# MoonBit Dotenv

A comprehensive MoonBit implementation of dotenv functionality for parsing and handling .env files, migrated and enhanced from the Deno standard library.

## Features

- **Parse .env file format** - Convert .env content to Map[String, String]
- **Stringify environment variables** - Convert Map back to .env format  
- **Comments support** - Lines starting with # are ignored
- **Quoted values** - Single and double quoted strings with escape sequences
- **Multiline strings** - Support for multiline values in double quotes
- **Variable expansion** - Support for $VAR and ${VAR} syntax with recursive expansion
- **Default values** - Support for ${VAR:-default} fallback syntax with nesting
- **Escaped variables** - Use \$VAR to prevent expansion
- **Whitespace handling** - Proper trimming and preservation based on quoting
- **Export prefix support** - Handles and ignores `export VAR=value` syntax
- **File-based loading** - Mock implementation compatible with future file system integration
- **Comprehensive test coverage** - Based on Deno std library test suite with 100+ test cases

## Quick Start

### Installation

Add the dotenv module to your MoonBit project:

```bash
moon add username/dotenv
```

### Basic Usage

```moonbit
// Parse .env content
let env_content = "GREETING=hello world\nPORT=3000\nDEBUG=true"
let parsed = @dotenv.parse(env_content)

// Access values
println(parsed.get("GREETING")) // Some("hello world")
println(parsed.get("PORT"))     // Some("3000")

// Convert back to .env format
let stringified = @dotenv.stringify(parsed)
println(stringified)
// Output:
// GREETING='hello world'
// PORT=3000
// DEBUG=true
```

### Advanced Variable Expansion

```moonbit
let env_content = 
  #|# Application configuration
  #|APP_NAME=MoonBit Dotenv Demo
  #|VERSION=2.0.0
  #|ENV=development
  #|
  #|# Variable expansion
  #|APP_TITLE=$APP_NAME v$VERSION
  #|FULL_INFO=${APP_NAME} version ${VERSION} (${ENV})
  #|
  #|# Default values
  #|DATABASE_URL=${DATABASE_URL:-sqlite://./default.db}
  #|PORT=${PORT:-8080}
  #|LOG_LEVEL=${LOG_LEVEL:-${DEFAULT_LOG_LEVEL:-info}}
  #|
  #|# Escaped variables
  #|USAGE_MSG=Set \$PORT to change the port
  #|

let parsed = @dotenv.parse(env_content)

// Results in expanded values:
// APP_TITLE = "MoonBit Dotenv Demo v2.0.0"
// FULL_INFO = "MoonBit Dotenv Demo version 2.0.0 (development)"
// DATABASE_URL = "sqlite://./default.db" (default used)
// PORT = "8080" (default used)
// LOG_LEVEL = "info" (nested default used)
// USAGE_MSG = "Set $PORT to change the port" (escaped)
```

### Load with Options

```moonbit
// Load from string with export option
let content = "API_KEY=secret123\nDEBUG=true"
let options = @dotenv.LoadOptions::with_export()
let config = @dotenv.load_from_string(content, options~)

// Load with custom path (mock implementation)
let prod_options = @dotenv.LoadOptions::with_path(".env.production")
let config = @dotenv.load_sync(options=prod_options)
```

## API Reference

### Core Functions

#### `parse(content: String) -> Map[String, String]`

Parse .env file content into a Map of environment variables.

**Parsing Rules:**
- Variables that already exist in the environment are not overridden with `export_vars: true`
- `BASIC=basic` becomes `{ BASIC: "basic" }`
- Empty lines are skipped
- Lines beginning with `#` are treated as comments
- Empty values become empty strings (`EMPTY=` becomes `{ EMPTY: "" }`)
- Single and double quoted values are escaped
- New lines are expanded in double quoted values (`MULTILINE="new\nline"`)
- Inner quotes are maintained (`JSON={"foo": "bar"}`)
- Whitespace is removed from both ends of unquoted values
- Whitespace is preserved on both ends of quoted values
- Dollar sign with environment key expands variables (`KEY=$VAR` or `KEY=${VAR}`)
- Escaped dollar sign prevents expansion (`KEY=\$VAR` becomes `KEY=$VAR`)
- Default value syntax provides fallbacks (`KEY=${VAR:-default}`)

#### `stringify(env: Map[String, String]) -> String`

Convert environment variables Map back to .env file format.

**Stringification Rules:**
- Basic values remain unquoted if they contain only word characters
- Values with spaces are wrapped in single quotes
- Values with newlines or single quotes use double quotes with escaping  
- Special characters trigger appropriate quoting
- Keys starting with `#` are ignored with warning

### Load Functions

#### `load_from_string(content: String, options?: LoadOptions) -> Map[String, String]`

Load and parse environment variables from string content.

#### `load_sync(options?: LoadOptions) -> Map[String, String]`

Load environment variables from file (mock implementation for future file system integration).

#### `auto_load() -> Unit`

Automatically load .env file and export to environment (mock implementation).

### LoadOptions

Configuration options for loading behavior:

```moonbit
pub struct LoadOptions {
  env_path : String?     // Optional path to .env file
  export_vars : Bool     // Whether to export to environment
}
```

**Convenience Constructors:**
- `LoadOptions::default()` - Load from ".env", no export
- `LoadOptions::with_path(path)` - Custom file path, no export
- `LoadOptions::with_export()` - Default path with export enabled
- `LoadOptions::with_path_and_export(path)` - Custom path with export
- `LoadOptions::no_file()` - No file loading, parse only

## .env Format Support

### Comments and Basic Values
```bash
# This is a comment
BASIC_VAR=basic value
EMPTY_VALUE=
NUMERIC_VALUE=42
```

### Quoted Values
```bash
# Single quotes preserve literal content
SINGLE_QUOTED='literal $VAR \n content'
PRESERVED_SPACES='  spaces preserved  '

# Double quotes allow escapes and expansion
DOUBLE_QUOTED="expanded $VAR content"
WITH_NEWLINES="line1\nline2\nline3"
ESCAPED_QUOTES="She said \"Hello\""
```

### Multiline Values
```bash
# Multiline in single quotes (literal)
SSH_KEY='
-----BEGIN RSA PRIVATE KEY-----
...key content...
-----END RSA PRIVATE KEY-----
'

# Multiline in double quotes (with escapes)
FORMATTED_TEXT="
Line 1 with \t tab
Line 2 with escaped \"quotes\"
Line 3 with expansion: $USER
"
```

### Variable Expansion
```bash
# Basic expansion
NAME=MoonBit
VERSION=1.0.0
APP_TITLE=$NAME v$VERSION

# Braced expansion  
APP_INFO=${NAME} version ${VERSION}

# Default values
PORT=${PORT:-8080}
DATABASE_URL=${DB_URL:-sqlite://./default.db}

# Nested defaults
LOG_LEVEL=${LOG_LEVEL:-${DEFAULT_LOG:-info}}

# Recursive expansion
BASE_URL=https://api.example.com
API_ENDPOINT=$BASE_URL/v1
FULL_ENDPOINT=${API_ENDPOINT}/data

# Escaped variables (no expansion)
USAGE_TEXT=Set \$PORT environment variable
CONFIG_EXAMPLE=Use \${VAR:-default} syntax
```

### Special Cases
```bash
# Export prefix is ignored but preserved in key
export EXPORTED_VAR=value

# Whitespace handling
  INDENTED_VAR=value
VAR_WITH_SPACE = trimmed value
QUOTED_SPACES='  preserved  '

# Equals signs in values
URL=https://example.com:8080/path?param=value&other=val
COMPLEX_VALUE=key1=val1;key2=val2

# Invalid keys are ignored (warnings shown)
1INVALID=starts with number
-INVALID=starts with hyphen
```

## Examples

### Real-world Configuration
```moonbit
let config_content = 
  #|# Application Configuration
  #|APP_NAME=My MoonBit App
  #|VERSION=1.2.3
  #|ENVIRONMENT=production
  #|
  #|# Database
  #|DB_HOST=${DB_HOST:-localhost}
  #|DB_PORT=${DB_PORT:-5432}
  #|DB_NAME=myapp_${ENVIRONMENT}
  #|DB_URL=postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}
  #|
  #|# API Configuration
  #|API_HOST=${API_HOST:-api.example.com}
  #|API_VERSION=v1
  #|API_BASE_URL=https://${API_HOST}/${API_VERSION}
  #|API_TIMEOUT=${API_TIMEOUT:-30}
  #|
  #|# Feature Flags
  #|ENABLE_LOGGING=${ENABLE_LOGGING:-true}
  #|DEBUG_MODE=${DEBUG_MODE:-false}
  #|ENABLE_CACHE=${ENABLE_CACHE:-true}
  #|

let config = @dotenv.parse(config_content)
// Use parsed configuration in your application
```

### Configuration File Generation
```moonbit
// Generate .env file from configuration
let app_config : Map[String, String] = Map::new()
app_config["NODE_ENV"] = "production"
app_config["PORT"] = "3000"
app_config["SECRET_KEY"] = "very-secret-key-here"
app_config["DATABASE_URL"] = "postgresql://user:pass@localhost/myapp"
app_config["REDIS_URL"] = "redis://localhost:6379"
app_config["LOG_LEVEL"] = "info"

let env_file_content = @dotenv.stringify(app_config)
// Write to file or use as template
```

### Testing Configuration
```moonbit
// Test environment setup
let test_env = 
  #|# Test Configuration
  #|NODE_ENV=test
  #|DATABASE_URL=sqlite://./test.db
  #|REDIS_URL=redis://localhost:6380
  #|LOG_LEVEL=debug
  #|ENABLE_DEBUG=true
  #|API_TIMEOUT=10
  #|

let test_config = @dotenv.parse(test_env)
// Apply test configuration
```

## Migration from Other Platforms

### From Node.js dotenv
```javascript
// Node.js
require('dotenv').config();
process.env.MY_VAR;
```

```moonbit
// MoonBit equivalent
let config = @dotenv.load_sync()
config.get("MY_VAR")
```

### From Deno std/dotenv
```typescript
// Deno
import { load } from "https://deno.land/std/dotenv/mod.ts";
const env = await load();
```

```moonbit
// MoonBit equivalent (API compatible)
let env = @dotenv.load()
```

## Testing

Run the comprehensive test suite:

```bash
moon test
```

The test suite includes:
- **Basic parsing tests** - Comments, quotes, whitespace handling
- **Variable expansion tests** - All syntax variations and edge cases
- **Stringify tests** - Round-trip compatibility and formatting
- **Load function tests** - Options and mock file operations  
- **Edge case tests** - Unicode, long lines, malformed input
- **Compatibility tests** - Deno std library test case coverage

## Performance

The implementation is optimized for:
- **Memory efficiency** - Streaming parsing without full string duplication
- **Parse speed** - Single-pass parsing with character-level processing
- **Large files** - Efficient handling of files with many variables
- **Complex expansion** - Recursive variable resolution with cycle detection

## Error Handling

The module provides robust error handling:
- **Invalid keys** - Warning messages for keys that don't match `/^[a-zA-Z_][a-zA-Z0-9_]*$/`
- **Malformed syntax** - Graceful handling of unclosed quotes or brackets
- **Circular references** - Prevention of infinite loops in variable expansion
- **File operations** - Mock implementations that simulate real-world error scenarios

## Compatibility

This implementation maintains compatibility with:
- **Deno std/dotenv** - API and behavior compatibility where applicable
- **Node.js dotenv** - Similar parsing rules and variable expansion
- **Docker .env files** - Standard .env format used in containerization
- **Shell environment** - Compatible with bash/shell variable syntax

## License

Apache-2.0

## Contributing

This module is based on the Deno standard library dotenv module. When contributing:

1. Ensure compatibility with the reference implementation
2. Add comprehensive test coverage for new features
3. Update documentation with examples
4. Follow MoonBit coding conventions and best practices
5. Maintain API compatibility where possible

See `dotenv_example.mbt` for comprehensive usage examples and `src/dotenv/comprehensive_test.mbt` for the complete test suite.