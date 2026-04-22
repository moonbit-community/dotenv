///| 文件操作工具集
///
/// 提供各种实用的文件操作功能和 .env 文件专用工具

///|
/// 异步读取文件的所有行
/// 
/// # 参数
/// - `file_path`: 文件路径
/// 
/// # 返回值
/// 文件行的数组
pub async fn read_lines(file_path : String) -> Array[String] raise {
  let content = read_file_content(file_path)
  let line_views = content.split("\n").to_array()
  let lines = Array::new()
  for view in line_views {
    lines.push(view.to_string())
  }
  lines
}

///|
/// 简单的 .env 文件格式验证
/// 
/// # 参数
/// - `env_file`: .env 文件路径
/// 
/// # 返回值
/// (是否有效, 错误消息数组)
/// 
/// # 注意
/// 这个函数只进行基本的格式验证，详细的解析需要使用 dotenv 包。
pub async fn validate_env_file_format(
  env_file : String,
) -> (Bool, Array[String]) raise {
  let content = read_file_content(env_file)
  validate_env_content_format(content)
}

///|
/// 验证 .env 内容格式
/// 
/// # 参数
/// - `content`: .env 文件内容
/// 
/// # 返回值
/// (是否有效, 错误消息数组)
pub fn validate_env_content_format(content : String) -> (Bool, Array[String]) {
  let line_views = content.split("\n").to_array()
  let errors = Array::new()
  let mut is_valid = true
  for i = 0; i < line_views.length(); i = i + 1 {
    let line_view = line_views[i]
    let line_str = line_view.to_string()
    let line = line_str.trim()
    let line_num = i + 1

    // 跳过空行和注释行
    if line == "" || (line.length() > 0 && line[0] == '#') {
      continue
    }

    // 检查是否包含等号
    if !(line.contains("=")) {
      errors.push("行 \{line_num}: 缺少等号 - '\{line}'")
      is_valid = false
    }
  }
  (is_valid, errors)
}
