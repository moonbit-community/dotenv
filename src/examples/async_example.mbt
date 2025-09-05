///| 异步文件操作实际应用示例
///
/// 演示如何在实际项目中使用异步文件操作 API

///|
/// 简化的配置管理示例
async fn config_manager_example() -> Unit noraise {
  println("=== 配置管理应用示例 ===")

  // 1. 创建开发环境配置
  let dev_config = Map::new()
  dev_config["DATABASE_URL"] = "postgresql://localhost:5432/myapp_dev"
  dev_config["REDIS_URL"] = "redis://localhost:6379"
  dev_config["JWT_SECRET"] = "dev-secret-123"
  dev_config["LOG_LEVEL"] = "debug"
  dev_config["PORT"] = "3001"
  dev_config["DEBUG"] = "true"
  try {
    let content = @dotenv.stringify(dev_config)
    @fileops.write_env_file_raw(".env.development", content)
    println("✓ 已创建开发环境配置: .env.development")
  } catch {
    err => println("创建配置文件失败: \{err}")
  }

  // 2. 验证配置文件格式
  try {
    let (is_valid, errors) = @fileops.validate_env_file_format(
      ".env.development",
    )
    if is_valid {
      println("✓ .env.development 格式正确")
    } else {
      println("✗ .env.development 有错误:")
      for error in errors {
        println("    \{error}")
      }
    }
  } catch {
    err => println("验证配置文件失败: \{err}")
  }

  // 3. 读取并解析配置文件
  try {
    let content = @fileops.read_env_file_content(".env.development")
    let parsed_vars = @dotenv.parse(content)
    println("✓ 解析得到 \{parsed_vars.size()} 个环境变量")
    for entry in parsed_vars {
      let (key, value) = entry
      println("  \{key}=\{value}")
    }
  } catch {
    err => println("读取配置文件失败: \{err}")
  }
}

///|
/// 文件操作示例
async fn file_operations_example() -> Unit noraise {
  println("\n=== 文件操作示例 ===")

  // 1. 创建一个测试文件
  let test_content = "# 测试配置文件\nTEST_VAR=test_value\nANOTHER_VAR=another_value"
  try {
    @fileops.write_file_content(".env.test", test_content)
    println("✓ 已创建测试文件: .env.test")
  } catch {
    err => println("创建测试文件失败: \{err}")
  }

  // 2. 检查文件是否存在
  let exists = @fileops.file_exists(".env.test")
  println("文件存在检查: \{exists}")

  // 3. 获取文件信息
  try {
    let (size, kind) = @fileops.get_file_info(".env.test")
    println("文件信息: 大小=\{size} 字节, 类型=\{kind}")
  } catch {
    err => println("获取文件信息失败: \{err}")
  }

  // 4. 读取文件行数
  try {
    let lines = @fileops.read_lines(".env.test")
    println("文件包含 \{lines.length()} 行")
    for i = 0; i < lines.length(); i = i + 1 {
      println("  行 \{i + 1}: \{lines[i]}")
    }
  } catch {
    err => println("读取文件行失败: \{err}")
  }
}

///|
/// 清理测试文件
async fn cleanup_test_files() -> Unit noraise {
  let test_files = [".env.development", ".env.test"]
  for file in test_files {
    let exists = @fileops.file_exists(file)
    if exists {
      try {
        @fileops.delete_file(file)
        println("✓ 已删除测试文件: \{file}")
      } catch {
        err => println("删除文件失败: \{file} - \{err}")
      }
    }
  }
}

///|
/// 主示例函数
fn main {
  @async.with_event_loop(_ =>  {
    println("开始异步文件操作应用示例...\n")
    config_manager_example()
    file_operations_example()
    cleanup_test_files()
    println("\n=== 所有示例完成 ===")
  }) catch {
    err => println("异步文件操作应用示例失败: \{err}")
  }
}
