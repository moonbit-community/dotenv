# MoonBit Dotenv - 异步文件操作模块

本模块为 MoonBit Dotenv 库提供了强大的异步文件操作功能，基于 `moonbitlang/async` 库构建。

## 功能特性

### 📁 基础文件操作
- 异步文件读取和写入
- 文件存在性检查
- 文件信息获取（大小、类型等）
- 目录内容读取
- 文件删除和复制

### 🔧 .env 文件专用操作
- 异步读取和解析 .env 文件
- 安全的 .env 文件写入（带备份）
- .env 文件格式验证
- 多个 .env 文件合并
- .env 文件差异比较

### 📖 缓冲读取功能
- 逐行读取大文件
- 模式搜索和行匹配
- 指定行范围读取
- 文件统计信息（行数、字符数、字节数）
- 文件大小监控

### 🛠️ 高级工具
- 配置文件模板生成
- 批量环境变量更新
- 配置清理和排序
- 环境变量使用搜索

## 快速开始

### 1. 添加依赖

确保你的 `moon.mod.json` 包含：

```json
{
  "deps": {
    "moonbitlang/async": "0.3.1"
  },
  "preferred-target": "native"
}
```

在 `moon.pkg.json` 中引入必要的包：

```json
{
  "import": [
    "moonbitlang/async",
    "moonbitlang/async/fs",
    "moonbitlang/async/io",
    "username/dotenv",
    "username/dotenv/fileops"
  ]
}
```

### 2. 基础用法

```moonbit
// 在异步上下文中运行
@async.with_event_loop(fn(root) {
  // 读取 .env 文件
  let env_vars = @fileops.read_env_file(".env")
  println("加载了 \{env_vars.size()} 个环境变量")
  
  // 写入新的 .env 文件
  let new_vars = Map::new()
  new_vars["DATABASE_URL"] = "postgresql://localhost/myapp"
  new_vars["DEBUG"] = "true"
  
  @fileops.write_env_file_safe("config.env", new_vars)
  println("已安全写入配置文件")
})
```

## API 参考

### 文件读取器 (`file_reader.mbt`)

#### `read_file_content(file_path: String) -> String`
异步读取文件的全部内容。

#### `read_env_file(env_file_path: String) -> Map[String, String]`
读取并解析 .env 文件为环境变量映射。

#### `file_exists(file_path: String) -> Bool`
检查文件是否存在。

#### `get_file_info(file_path: String) -> (Int64, String)`
获取文件大小和类型信息。

#### `read_directory(dir_path: String) -> Array[String]`
读取目录中的所有文件名。

#### `find_env_files(dir_path: String) -> Array[String]`
查找目录中的所有 .env 文件。

### 文件写入器 (`file_writer.mbt`)

#### `write_file_content(file_path: String, content: String, permission~: Int = 0o644) -> Unit`
写入文件内容，可指定权限。

#### `write_env_file(env_file_path: String, env_vars: Map[String, String]) -> Unit`
将环境变量映射写入 .env 文件。

#### `write_env_file_safe(env_file_path: String, env_vars: Map[String, String]) -> Unit`
安全写入 .env 文件，会先创建备份。

#### `append_file_content(file_path: String, content: String) -> Unit`
追加内容到文件末尾。

#### `copy_file(source_path: String, dest_path: String) -> Unit`
复制文件。

### 缓冲读取器 (`buffered_reader.mbt`)

#### `read_lines(file_path: String) -> Array[String]`
逐行读取文件内容。

#### `find_lines_with_pattern(file_path: String, pattern: String) -> Array[(Int, String)]`
查找包含特定模式的行，返回行号和内容。

#### `read_line_range(file_path: String, start_line: Int, end_line: Int) -> Array[String]`
读取指定行范围的内容。

#### `file_stats(file_path: String) -> (Int, Int, Int64)`
获取文件统计信息：行数、字符数、字节数。

### 文件工具 (`file_utils.mbt`)

#### `merge_env_files(env_files: Array[String], output_file: String) -> Map[String, String]`
合并多个 .env 文件。

#### `compare_env_files(file1: String, file2: String) -> (Map[String, String], Map[String, String], Map[String, (String, String)])`
比较两个 .env 文件的差异。

#### `validate_env_file(env_file: String) -> (Bool, Array[String])`
验证 .env 文件格式。

#### `cleanup_env_file(env_file: String, sort_keys~: Bool = true) -> Unit`
清理 .env 文件，移除重复项并可选排序。

#### `create_env_template(template_file: String, example_vars: Map[String, String]) -> Unit`
创建 .env 文件模板。

## 实际应用示例

### 配置管理

```moonbit
@async.with_event_loop(fn(root) {
  // 创建开发和生产环境配置
  let dev_config = Map::new()
  dev_config["DATABASE_URL"] = "postgresql://localhost/app_dev"
  dev_config["DEBUG"] = "true"
  
  let prod_config = Map::new()
  prod_config["DATABASE_URL"] = "postgresql://prod-server/app"
  prod_config["DEBUG"] = "false"
  
  @fileops.write_env_file(".env.development", dev_config)
  @fileops.write_env_file(".env.production", prod_config)
  
  // 比较差异
  let (dev_only, prod_only, different) = @fileops.compare_env_files(
    ".env.development", 
    ".env.production"
  )
  
  println("环境配置差异分析完成")
})
```

### 配置迁移

```moonbit
@async.with_event_loop(fn(root) {
  // 读取旧格式配置
  let old_vars = @fileops.read_env_file(".env.old")
  
  // 转换为新格式
  let mut new_vars = Map::new()
  let db_host = old_vars.get("DB_HOST").or("localhost")
  let db_port = old_vars.get("DB_PORT").or("5432")
  let db_name = old_vars.get("DB_NAME").or("app")
  
  new_vars["DATABASE_URL"] = "postgresql://\{db_host}:\{db_port}/\{db_name}"
  
  // 安全写入新配置
  @fileops.write_env_file_safe(".env.new", new_vars)
  
  println("配置迁移完成")
})
```

### 批量处理

```moonbit
@async.with_event_loop(fn(root) {
  // 查找所有 .env 文件
  let env_files = @fileops.find_env_files("./configs")
  
  // 批量更新
  let updates = Map::new()
  updates["LOG_LEVEL"] = "info"
  updates["UPDATED_AT"] = "2024-01-01T00:00:00Z"
  
  @fileops.batch_update_env_vars(env_files, updates)
  
  println("批量更新完成，影响 \{env_files.length()} 个文件")
})
```

## 错误处理

所有异步函数都使用 `raise` 关键字声明异常，你可以使用 `try-catch` 进行错误处理：

```moonbit
@async.with_event_loop(fn(root) {
  try {
    let content = @fileops.read_file_content("config.env")
    println("文件读取成功")
  } catch {
    err => println("文件读取失败: \{err}")
  }
})
```

## 性能建议

1. **使用缓冲读取器**：对于大文件，使用 `buffered_reader.mbt` 中的函数。
2. **批量操作**：尽可能使用批量函数而不是循环调用单个函数。
3. **安全写入**：对重要配置文件使用 `write_env_file_safe` 以确保数据安全。
4. **适当的权限**：为创建的文件设置合适的权限（默认 0o644）。

## 运行演示

你可以运行以下命令查看功能演示：

```bash
# 基础异步文件操作演示
moon run src/examples/main --async

# 查看帮助
moon run src/examples/main --help
```

## 注意事项

1. 所有异步操作必须在 `@async.with_event_loop` 上下文中执行
2. 使用 `defer` 确保文件资源被正确释放
3. 对于生产环境，建议添加更多的错误处理和验证
4. 某些功能（如目录创建）需要系统级权限

更多信息请参考 MoonBit 异步编程指南和 `moonbitlang/async` 库文档。