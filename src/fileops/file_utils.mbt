///| 文件操作工具集
///
/// 提供各种实用的文件操作功能和 .env 文件专用工具

///| 简单的 .env 文件验证
/// 
/// # 参数
/// - `env_file`: .env 文件路径
/// 
/// # 返回值
/// (是否有效, 错误消息数组)
pub async fn validate_env_file(
  env_file : String,
) -> (Bool, Array[String]) raise {
  let lines = read_lines(env_file)
  let errors = Array::new()
  let mut is_valid = true
  for i = 0; i < lines.length(); i = i + 1 {
    let line = lines[i]
    let line_num = i + 1

    // 跳过空行和注释行
    if line == "" || (line.length() > 0 && line[0] == '#') {
      continue
    }

    // 检查是否包含等号
    if not(line.contains("=")) {
      errors.push("行 \{line_num}: 缺少等号 - '\{line}'")
      is_valid = false
    }
  }
  (is_valid, errors)
}
