///| 缓冲文件读取器
///
/// 提供高效的缓冲文件读取功能，特别适用于大文件处理

// Helper functions are defined in file_reader.mbt and file_writer.mbt

///|
/// 使用缓冲方式逐行读取文件内容
/// 
/// # 参数
/// - `file_path`: 文件路径
/// 
/// # 返回值
/// 文件行的数组
/// 
/// # 错误
/// 如果读取失败会抛出异常
pub async fn read_lines_buffered(file_path : String) -> Array[String] raise {
  let file = @fs.open(string_to_utf8_bytes(file_path), mode=ReadOnly)
  defer file.close()

  // 简化实现：直接读取全部内容然后按行分割
  let content = file.read_all()
  let content_str = utf8_bytes_to_string(content)

  // 按换行符分割
  let lines = Array::new()
  let mut current_pos = 0
  let content_len = content_str.length()
  while current_pos < content_len {
    let mut line_end = current_pos

    // 寻找下一个换行符
    while line_end < content_len && content_str[line_end] != '\n' {
      line_end = line_end + 1
    }

    // 提取行内容
    let line = content_str[current_pos:line_end]

    // 移除可能的回车符
    let clean_line = match line.strip_suffix("\r") {
      Some(stripped) => stripped
      None => line
    }
    if clean_line.length() > 0 || line_end < content_len {
      lines.push(clean_line.to_string())
    }
    current_pos = line_end + 1
  }
  lines
}

///|
/// 查找文件中包含特定模式的行
/// 
/// # 参数
/// - `file_path`: 文件路径
/// - `pattern`: 要查找的模式
/// 
/// # 返回值
/// 包含模式的行及其行号的数组
pub async fn find_lines_with_pattern(
  file_path : String,
  pattern : String,
) -> Array[(Int, String)] raise {
  let lines = read_lines_buffered(file_path)
  let matches = Array::new()
  for i = 0; i < lines.length(); i = i + 1 {
    let line = lines[i]
    if line.contains(pattern) {
      matches.push((i + 1, line)) // 行号从1开始
    }
  }
  matches
}

///|
/// 读取文件的指定行范围
/// 
/// # 参数
/// - `file_path`: 文件路径
/// - `start_line`: 起始行号（从1开始）
/// - `end_line`: 结束行号（包含，从1开始）
/// 
/// # 返回值
/// 指定范围内的行
pub async fn read_line_range(
  file_path : String,
  start_line : Int,
  end_line : Int,
) -> Array[String] raise {
  let lines = read_lines_buffered(file_path)
  let result = Array::new()
  let start_idx = start_line - 1 // 转换为0索引
  let end_idx = end_line - 1
  if start_idx >= 0 &&
    start_idx < lines.length() &&
    end_idx >= start_idx &&
    end_idx < lines.length() {
    for i = start_idx; i <= end_idx; i = i + 1 {
      result.push(lines[i])
    }
  }
  result
}

///|
/// 统计文件信息
/// 
/// # 参数
/// - `file_path`: 文件路径
/// 
/// # 返回值
/// (行数, 字符数, 字节数) 的元组
pub async fn file_stats(file_path : String) -> (Int, Int, Int64) raise {
  let file = @fs.open(string_to_utf8_bytes(file_path), mode=ReadOnly)
  defer file.close()
  let content = file.read_all()
  let content_str = utf8_bytes_to_string(content)
  let lines = read_lines_buffered(file_path)
  let line_count = lines.length()
  let char_count = content_str.length()
  let byte_count = file.size()
  (line_count, char_count, byte_count)
}

///|
/// 监控文件大小变化（简单实现）
/// 
/// # 参数
/// - `file_path`: 文件路径
/// - `check_interval_ms`: 检查间隔（毫秒）
/// - `max_checks`: 最大检查次数
/// 
/// # 返回值
/// 文件大小变化的数组
pub async fn monitor_file_size(
  file_path : String,
  check_interval_ms? : Int = 1000,
  max_checks? : Int = 10,
) -> Array[Int64] raise {
  let sizes = Array::new()
  for i = 0; i < max_checks; i = i + 1 {
    if file_exists(file_path) {
      let (size, _) = get_file_info(file_path)
      sizes.push(size)
    } else {
      sizes.push(-1L) // 文件不存在
    }
    if i < max_checks - 1 {
      @async.sleep(check_interval_ms)
    }
  }
  sizes
}
