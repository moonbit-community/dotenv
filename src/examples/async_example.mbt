///| 异步文件操作实际应用示例
///
/// 演示如何在实际项目中使用异步文件操作 API

/// 配置管理应用示例
async fn config_manager_example() -> Unit raise {
  println("=== 配置管理应用示例 ===")
  
  // 1. 创建配置文件模板
  let default_config = Map::new()
  default_config["DATABASE_URL"] = "postgresql://localhost:5432/myapp"
  default_config["REDIS_URL"] = "redis://localhost:6379"
  default_config["JWT_SECRET"] = "your-secret-here"
  default_config["LOG_LEVEL"] = "info"
  default_config["PORT"] = "3000"
  
  @fileops.create_env_template(".env.template", default_config)
  println("✓ 已创建配置模板: .env.template")
  
  // 2. 创建开发环境配置
  let dev_config = Map::new()
  dev_config["DATABASE_URL"] = "postgresql://localhost:5432/myapp_dev"
  dev_config["REDIS_URL"] = "redis://localhost:6379"
  dev_config["JWT_SECRET"] = "dev-secret-123"
  dev_config["LOG_LEVEL"] = "debug"
  dev_config["PORT"] = "3001"
  dev_config["DEBUG"] = "true"
  
  @fileops.write_env_file(".env.development", dev_config)
  println("✓ 已创建开发环境配置: .env.development")
  
  // 3. 创建生产环境配置
  let prod_config = Map::new()
  prod_config["DATABASE_URL"] = "postgresql://prod-db:5432/myapp"
  prod_config["REDIS_URL"] = "redis://prod-redis:6379"
  prod_config["JWT_SECRET"] = "prod-secret-xyz"
  prod_config["LOG_LEVEL"] = "warn"
  prod_config["PORT"] = "80"
  prod_config["NODE_ENV"] = "production"
  
  @fileops.write_env_file(".env.production", prod_config)
  println("✓ 已创建生产环境配置: .env.production")
  
  // 4. 验证配置文件
  let environments = [".env.development", ".env.production"]
  for env_file in environments {
    let (is_valid, errors) = @fileops.validate_env_file(env_file)
    if is_valid {
      println("✓ \{env_file} 格式正确")
    } else {
      println("✗ \{env_file} 有错误:")
      for error in errors {
        println("    \{error}")
      }
    }
  }
  
  // 5. 比较开发和生产环境差异
  let (dev_only, prod_only, different) = @fileops.compare_env_files(
    ".env.development", 
    ".env.production"
  )
  
  println("\n环境差异分析:")
  if dev_only.size() > 0 {
    println("  仅在开发环境:")
    for entry in dev_only {
      let (key, value) = entry
      println("    \{key}=\{value}")
    }
  }
  
  if prod_only.size() > 0 {
    println("  仅在生产环境:")
    for entry in prod_only {
      let (key, value) = entry
      println("    \{key}=\{value}")
    }
  }
  
  if different.size() > 0 {
    println("  值不同的变量:")
    for entry in different {
      let (key, values) = entry
      let (dev_val, prod_val) = values
      println("    \{key}: dev('\{dev_val}') vs prod('\{prod_val}')")
    }
  }
}

/// 环境变量迁移示例
async fn env_migration_example() -> Unit raise {
  println("\n=== 环境变量迁移示例 ===")
  
  // 1. 创建旧版本配置文件
  let old_config = Map::new()
  old_config["DB_HOST"] = "localhost"
  old_config["DB_PORT"] = "5432"
  old_config["DB_NAME"] = "myapp"
  old_config["DB_USER"] = "user"
  old_config["DB_PASS"] = "password"
  old_config["CACHE_HOST"] = "localhost"
  old_config["CACHE_PORT"] = "6379"
  
  @fileops.write_env_file(".env.old", old_config)
  println("✓ 已创建旧版本配置: .env.old")
  
  // 2. 定义迁移规则（将分散的数据库配置合并为 URL）
  let old_vars = @fileops.read_env_file(".env.old")
  let mut new_vars = Map::new()
  
  // 构建新的 DATABASE_URL
  let db_host = old_vars.get("DB_HOST").or("localhost")
  let db_port = old_vars.get("DB_PORT").or("5432")
  let db_name = old_vars.get("DB_NAME").or("myapp")
  let db_user = old_vars.get("DB_USER").or("user")
  let db_pass = old_vars.get("DB_PASS").or("password")
  
  new_vars["DATABASE_URL"] = "postgresql://\{db_user}:\{db_pass}@\{db_host}:\{db_port}/\{db_name}"
  
  // 构建新的 REDIS_URL
  let cache_host = old_vars.get("CACHE_HOST").or("localhost")
  let cache_port = old_vars.get("CACHE_PORT").or("6379")
  new_vars["REDIS_URL"] = "redis://\{cache_host}:\{cache_port}"
  
  // 保留其他可能存在的配置
  for entry in old_vars {
    let (key, value) = entry
    if not(key.starts_with("DB_")) && not(key.starts_with("CACHE_")) {
      new_vars[key] = value
    }
  }
  
  @fileops.write_env_file(".env.new", new_vars)
  println("✓ 已创建迁移后的配置: .env.new")
  
  // 3. 显示迁移结果
  println("\n迁移结果:")
  println("  旧配置变量数: \{old_vars.size()}")
  println("  新配置变量数: \{new_vars.size()}")
  
  let new_content = @fileops.read_file_content(".env.new")
  println("\n新配置内容:")
  println(new_content)
}

/// 项目部署检查示例
async fn deployment_check_example() -> Unit raise {
  println("\n=== 项目部署检查示例 ===")
  
  // 1. 定义必需的环境变量
  let required_vars = ["DATABASE_URL", "REDIS_URL", "JWT_SECRET", "PORT"]
  let optional_vars = ["DEBUG", "LOG_LEVEL", "NODE_ENV"]
  
  // 2. 检查生产环境配置
  let prod_vars = @fileops.read_env_file(".env.production")
  
  println("检查生产环境配置...")
  let mut missing_required = Array::new()
  let mut missing_optional = Array::new()
  
  for var_name in required_vars {
    if not(prod_vars.contains(var_name)) {
      missing_required.push(var_name)
    } else {
      println("✓ 必需变量 \{var_name} 已配置")
    }
  }
  
  for var_name in optional_vars {
    if not(prod_vars.contains(var_name)) {
      missing_optional.push(var_name)
    } else {
      println("✓ 可选变量 \{var_name} 已配置")
    }
  }
  
  // 3. 报告检查结果
  if missing_required.length() > 0 {
    println("\n❌ 缺少必需的环境变量:")
    for var_name in missing_required {
      println("    \{var_name}")
    }
  } else {
    println("\n✅ 所有必需的环境变量都已配置")
  }
  
  if missing_optional.length() > 0 {
    println("\n⚠️  缺少可选的环境变量:")
    for var_name in missing_optional {
      println("    \{var_name}")
    }
  }
  
  // 4. 安全性检查
  println("\n安全性检查:")
  for entry in prod_vars {
    let (key, value) = entry
    if key.contains("SECRET") || key.contains("PASSWORD") || key.contains("KEY") {
      if value.length() < 8 {
        println("⚠️  \{key} 的值可能过短（安全风险）")
      } else {
        println("✓ \{key} 长度合适")
      }
    }
  }
}

/// 清理测试文件
async fn cleanup_test_files() -> Unit {
  let test_files = [
    ".env.template",
    ".env.development", 
    ".env.production",
    ".env.old",
    ".env.new"
  ]
  
  for file in test_files {
    if @fileops.file_exists(file) {
      try {
        @fileops.delete_file(file)
      } catch {
        _ => () // 忽略删除错误
      }
    }
  }
  println("\n✓ 已清理测试文件")
}

/// 主示例函数
pub async fn run_async_examples() -> Unit raise {
  println("开始异步文件操作应用示例...\n")
  
  config_manager_example()
  env_migration_example()
  deployment_check_example()
  cleanup_test_files()
  
  println("\n=== 所有示例完成 ===")
}