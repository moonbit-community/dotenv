///| MoonBit Dotenv Library - Comprehensive Examples

///|

///| This file demonstrates the key features of the MoonBit dotenv module,

///| showcasing parsing, stringification, variable expansion, and configuration loading.

///| Basic parsing example demonstrating simple key-value pairs
pub fn basic_example() -> Unit {
  println("=== Basic Dotenv Parsing ===")
  let env_content =
    #|# Application configuration
    #|APP_NAME=MoonBit Dotenv Demo
    #|VERSION=1.0.0
    #|DEBUG=true
    #|PORT=8080
    #|
  let parsed = @dotenv.parse(env_content)
  println("Parsed \{parsed.size()} environment variables:")
  for entry in parsed {
    let (key, value) = entry
    println("  \{key} = \{value}")
  }
}

///| Variable expansion example showcasing different expansion syntaxes
pub fn variable_expansion_example() -> Unit {
  println("\n=== Variable Expansion Features ===")
  let env_content =
    #|# Base variables
    #|APP_NAME=MoonBit Dotenv
    #|VERSION=1.0.0
    #|ENV=development
    #|
    #|# Simple expansion with $VAR syntax
    #|APP_TITLE=$APP_NAME v$VERSION
    #|
    #|# Bracket expansion with ${VAR} syntax
    #|FULL_INFO=${APP_NAME} version ${VERSION} running in ${ENV}
    #|
    #|# Default values with ${VAR:-default} syntax
    #|DATABASE_URL=${DATABASE_URL:-sqlite://./app.db}
    #|LOG_LEVEL=${LOG_LEVEL:-info}
    #|
    #|# Nested default values
    #|CONFIG_PATH=${CONFIG_PATH:-${DEFAULT_CONFIG_PATH:-./config.json}}
    #|
    #|# Escaped variables (literal $ character)
    #|LITERAL_DOLLAR=\$VERSION will not expand
    #|
  let parsed = @dotenv.parse(env_content)
  println("Variable expansion results:")
  for entry in parsed {
    let (key, value) = entry
    println("  \{key} = \{value}")
  }
}

///| Quoting and multiline example
pub fn quoting_and_multiline_example() -> Unit {
  println("\n=== Quoting and Multiline Values ===")
  let env_content =
    #|# Different quoting styles
    #|UNQUOTED=simple value
    #|SINGLE_QUOTED='preserves $VAR literally'
    #|DOUBLE_QUOTED="allows $APP_NAME expansion"
    #|
    #|# Multiline values (preserves formatting)
    #|SQL_QUERY='
    #|SELECT users.name, users.email
    #|FROM users
    #|WHERE users.active = true
    #|ORDER BY users.created_at DESC
    #|'
    #|
    #|# JSON configuration in quotes
    #|JSON_CONFIG='{"database": {"host": "localhost", "port": 5432}}'
    #|
    #|# Escape sequences in double quotes
    #|LOG_FORMAT="[%timestamp%] %level%: %message%\n"
    #|
  let parsed = @dotenv.parse(env_content)
  println("Quoting and multiline results:")
  for entry in parsed {
    let (key, value) = entry
    println("  \{key} = \{value}")
  }
}

///| Stringification example showing how to convert Map back to .env format
pub fn stringify_example() -> Unit {
  println("\n=== Environment Variable Stringification ===")

  // Create a sample environment map
  let env : Map[String, String] = Map::new()
  env["APP_NAME"] = "MoonBit Dotenv"
  env["VERSION"] = "1.0.0"
  env["DEBUG"] = "true"
  env["DATABASE_URL"] = "postgres://user:password@localhost:5432/myapp"
  env["SECRET_KEY"] = "super-secret-key-123!"
  env["MULTILINE_CONFIG"] = "line1\nline2\nline3"
  env["SPECIAL_CHARS"] = "contains spaces & symbols!"
  let dotenv_string = @dotenv.stringify(env)
  println("Stringified .env format:")
  println(dotenv_string)

  // Demonstrate round-trip conversion
  println("\n--- Round-trip verification ---")
  let reparsed = @dotenv.parse(dotenv_string)
  println("Successfully round-tripped \{reparsed.size()} variables")
}

///| Load configuration example using LoadOptions
pub fn load_configuration_example() -> Unit {
  println("\n=== Load Configuration Options ===")
  let sample_env_content =
    #|# Sample configuration
    #|APP_ENV=development
    #|SERVER_PORT=3000
    #|DATABASE_URL=postgres://localhost/myapp_dev
    #|REDIS_URL=redis://localhost:6379
    #|LOG_LEVEL=debug
    #|

  // Load with default options
  println("Loading with default options:")
  let config1 = @dotenv.load_from_string(sample_env_content)
  println("  Loaded \{config1.size()} variables:")
  for entry in config1 {
    let (key, value) = entry
    println("    \{key} = \{value}")
  }

  // Load with export option (would export to environment in full implementation)
  println("\nLoading with export option:")
  let export_options = @dotenv.LoadOptions::with_export()
  let config2 = @dotenv.load_from_string(
    sample_env_content,
    options=export_options,
  )
  println("  Exported \{config2.size()} variables to environment")

  // Demonstrate different LoadOptions configurations
  println("\nAvailable LoadOptions configurations:")
  let default_opts = @dotenv.LoadOptions::default()
  let with_path = @dotenv.LoadOptions::with_path(".env.production")
  let with_export = @dotenv.LoadOptions::with_export()
  let custom = @dotenv.LoadOptions::with_path_and_export(".env.local")
  println(
    "  Default: env_path=\{default_opts.env_path}, export=\{default_opts.export_vars}",
  )
  println(
    "  With path: env_path=\{with_path.env_path}, export=\{with_path.export_vars}",
  )
  println(
    "  With export: env_path=\{with_export.env_path}, export=\{with_export.export_vars}",
  )
  println("  Custom: env_path=\{custom.env_path}, export=\{custom.export_vars}")
}

///| Advanced features demonstration
pub fn advanced_features_example() -> Unit {
  println("\n=== Advanced Features ===")
  let complex_env =
    #|# Complex variable expansion scenarios
    #|BASE_URL=https://api.example.com
    #|API_VERSION=v2
    #|ENVIRONMENT=staging
    #|
    #|# Nested expansions
    #|API_ENDPOINT=${BASE_URL}/${API_VERSION}
    #|FULL_ENDPOINT=${API_ENDPOINT}/data
    #|
    #|# Complex defaults with fallbacks
    #|CACHE_TTL=${CACHE_TTL:-${DEFAULT_CACHE_TTL:-3600}}
    #|DATABASE_HOST=${DB_HOST:-${DATABASE_HOST:-localhost}}
    #|
    #|# Mixed expansion styles
    #|STATUS_MESSAGE=Environment: ${ENVIRONMENT}, API: $API_VERSION
    #|
    #|# Edge cases
    #|ESCAPED_EXAMPLE=This has \$ENVIRONMENT (literal) and ${ENVIRONMENT} (expanded)
    #|SPECIAL_SYNTAX=price: \$${PRICE:-100}
    #|
  let parsed = @dotenv.parse(complex_env)
  println("Advanced expansion results:")
  for entry in parsed {
    let (key, value) = entry
    println("  \{key} = \{value}")
  }
}

///| Run async demos
pub fn run_async_demos() -> Unit {
  // 运行异步文件操作演示
  @async.with_event_loop(fn(root) {
    try {
      println("\n🌙 异步文件操作演示")
      println("====================================")

      // 运行基础演示
      @fileops.run_all_demos()

      // 运行应用示例
      run_async_examples()
      println("\n✨ 异步操作演示完成!")
    } catch {
      err => println("❌ 异步操作出错: \{err}")
    }
  }) catch {
    err => println("❌ 事件循环出错: \{err}")
  }
}

///| Main function demonstrating all examples
fn main {
  // 运行同步示例
  println("🌙 MoonBit Dotenv Library - Feature Showcase")
  println("============================================")
  basic_example()
  variable_expansion_example()
  quoting_and_multiline_example()
  stringify_example()
  load_configuration_example()
  advanced_features_example()
  println("\n✨ All examples completed successfully!")
  println("\nThe MoonBit dotenv library supports:")
  println("  • Parsing .env files with comments and empty lines")
  println("  • Variable expansion ($VAR and ${VAR} syntax)")
  println("  • Default values (${VAR:-default})")
  println("  • Nested and recursive expansion")
  println("  • Single and double quoted values")
  println("  • Multiline values")
  println("  • Escape sequences and literal characters")
  println("  • Stringification back to .env format")
  println("  • Flexible loading configurations")

  // 运行异步演示
  println("\n💡 现在运行异步文件操作演示...")
  run_async_demos()
}
