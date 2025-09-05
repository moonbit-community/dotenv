///| 异步文件读取器
///
/// 提供异步文件系统操作功能，特别针对 .env 文件的读取和处理
/// 
/// # 示例
/// 
/// ```moonbit
/// @async.with_event_loop(fn(root) {
///   let content = read_env_file("config.env")
///   println("读取到内容: \{content}")
/// })
/// ```

// Encoding utilities are now in encoding_utils.mbt

///|
/// 异步读取文件内容
/// 
/// # 参数
/// - `file_path`: 文件路径
/// 
/// # 返回值
/// 文件内容字符串（UTF-8 解码）
/// 
/// # 错误
/// 如果文件不存在或读取失败，会抛出异常
pub async fn read_file_content(file_path : String) -> String raise {
  let file = @fs.open(string_to_utf8_bytes(file_path), mode=ReadOnly)
  defer file.close()
  let content = file.read_all()
  utf8_bytes_to_string(content)
}

///|
/// 异步读取 .env 文件内容（原始字符串）
/// 
/// # 参数
/// - `env_file_path`: .env 文件路径
/// 
/// # 返回值
/// 原始的 .env 文件内容字符串，需要使用 dotenv 库进行解析
/// 
/// # 注意
/// 这个函数只负责文件读取，不进行解析。解析需要使用 dotenv 包的 parse 函数。
pub async fn read_env_file_raw(env_file_path : String) -> String raise {
  read_env_file_content(env_file_path)
}

///|
/// 异步读取 .env 文件内容（不解析）
/// 
/// # 参数  
/// - `env_file_path`: .env 文件路径
/// 
/// # 返回值
/// 原始文件内容字符串
pub async fn read_env_file_content(env_file_path : String) -> String raise {
  read_file_content(env_file_path)
}

///|
/// 检查文件是否存在
/// 
/// # 参数
/// - `file_path`: 文件路径
/// 
/// # 返回值
/// 如果文件存在返回 true，否则返回 false
pub async fn file_exists(file_path : String) -> Bool noraise {
  try {
    let file = @fs.open(string_to_utf8_bytes(file_path), mode=ReadOnly)
    file.close()
    true
  } catch {
    _ => false
  }
}

///|
/// 获取文件信息
/// 
/// # 参数
/// - `file_path`: 文件路径
/// 
/// # 返回值
/// 包含文件大小和类型的元组
pub async fn get_file_info(file_path : String) -> (Int64, String) raise {
  let file = @fs.open(string_to_utf8_bytes(file_path), mode=ReadOnly)
  defer file.close()
  let size = file.size()
  let kind = match file.kind() {
    Regular => "file"
    Directory => "directory"
    SymLink => "symlink"
    Socket => "socket"
    Pipe => "pipe"
    _ => "unknown"
  }
  (size, kind)
}

///|
/// 异步读取目录内容
/// 
/// # 参数
/// - `dir_path`: 目录路径
/// 
/// # 返回值
/// 目录中文件名的数组（UTF-8 解码）
pub async fn read_directory(dir_path : String) -> Array[String] raise {
  let dir_file = @fs.open(string_to_utf8_bytes(dir_path), mode=ReadOnly)
  defer dir_file.close()
  let dir = dir_file.as_dir()
  let files = dir.read_all()
  let result = Array::new()
  for file in files {
    result.push(utf8_bytes_to_string(file))
  }
  result
}

///|
/// 查找目录中的所有 .env 文件
/// 
/// # 参数
/// - `dir_path`: 目录路径
/// 
/// # 返回值
/// .env 文件路径的数组
pub async fn find_env_files(dir_path : String) -> Array[String] raise {
  let files = read_directory(dir_path)
  let env_files = Array::new()
  for file in files {
    let is_env_file = match file.strip_suffix(".env") {
      Some(_) => true
      None => file == ".env"
    }
    if is_env_file {
      let full_path = match dir_path.strip_suffix("/") {
        Some(path_without_slash) => path_without_slash.to_string() + "/" + file
        None => dir_path + "/" + file
      }
      env_files.push(full_path)
    }
  }
  env_files
}
