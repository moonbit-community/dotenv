///| 异步文件操作演示
///
/// 展示如何使用异步文件操作 API 来处理 .env 文件和其他文件操作

///|
/// 演示基本文件读写操作
pub async fn demo_basic_file_ops() -> Unit {
  println("=== 基本文件操作演示 ===")

  // 创建测试内容
  let test_content = "# Test .env file\nDATABASE_URL=postgresql://localhost/test\nDEBUG=true\nPORT=3000\n"
  let test_file = "test.env"

  // 写入文件
  write_file_content(test_file, test_content)
  println("✓ 已写入测试文件: \{test_file}")

  // 读取文件
  let content = read_file_content(test_file)
  println("✓ 读取到内容:")
  println(content)

  // 检查文件信息
  let (size, kind) = get_file_info(test_file)
  println("✓ 文件信息: 大小=\{size}字节, 类型=\{kind}")

  // 解析为环境变量
  let env_content = read_env_file_content(test_file)
  println(
    "✓ 读取了环境文件内容，长度: \{env_content.length()} 字符",
  )

  // 清理
  delete_file(test_file)
  println("✓ 已删除测试文件")
}

///|
/// 演示错误处理
pub async fn demo_error_handling() -> Unit {
  println("\n=== 错误处理演示 ===")

  // 尝试读取不存在的文件
  let non_existent = "does_not_exist.env"
  if file_exists(non_existent) {
    println("文件存在: \{non_existent}")
  } else {
    println("✓ 文件不存在: \{non_existent}")
  }

  // 安全地尝试读取文件
  ignore(
    read_file_content(non_existent) catch {
      _ => {
        println("✓ 预期的错误: 无法读取不存在的文件")
        ""
      }
    },
  )

  // 创建格式错误的 .env 文件
  let bad_content = "VALID_VAR=value\nINVALID LINE WITHOUT EQUALS\nANOTHER_VALID=value2\n"
  write_file_content("bad.env", bad_content)
  let (is_valid, errors) = validate_env_file_format("bad.env")
  println("✓ 格式验证结果: 有效=\{is_valid}")
  if !is_valid {
    println("  发现的错误:")
    for error in errors {
      println("    \{error}")
    }
  }
  delete_file("bad.env")
}

///|
/// 主演示函数
pub async fn run_all_demos() -> Unit {
  println("开始异步文件操作演示...")
  demo_basic_file_ops()
  demo_error_handling()
  println("\n=== 演示完成 ===")
}
