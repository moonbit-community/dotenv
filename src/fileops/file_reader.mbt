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

///| 将 String 转换为 Bytes（用于文件路径等）
fn String::to_ascii(str : String) -> Bytes {
  Bytes::makei(str.length(), i => str.unsafe_charcode_at(i).to_byte())
}

///| 将 Bytes 转换为 String（用于文件内容显示）
fn ascii_to_string(ascii : @bytes.View) -> String {
  let builder = StringBuilder::new()
  for byte in ascii {
    builder.write_char(byte.to_int().unsafe_to_char())
  }
  builder.to_string()
}

///| 异步读取文件内容
/// 
/// # 参数
/// - `file_path`: 文件路径
/// 
/// # 返回值
/// 文件内容字符串
/// 
/// # 错误
/// 如果文件不存在或读取失败，会抛出异常
pub async fn read_file_content(file_path : String) -> String raise {
  let file = @fs.open(file_path.to_ascii(), mode=ReadOnly)
  defer file.close()
  let content = file.read_all()
  ascii_to_string(content)
}

///| 异步读取 .env 文件并解析为环境变量映射
/// 
/// # 参数
/// - `env_file_path`: .env 文件路径
/// 
/// # 返回值
/// 解析后的环境变量 Map
pub async fn read_env_file(env_file_path : String) -> Map[String, String] raise {
  let content = read_env_file_content(env_file_path)
  @dotenv.parse(content)
}

///| 异步读取 .env 文件内容（不解析）
/// 
/// # 参数  
/// - `env_file_path`: .env 文件路径
/// 
/// # 返回值
/// 原始文件内容字符串
pub async fn read_env_file_content(env_file_path : String) -> String raise {
  read_file_content(env_file_path)
}

///| 检查文件是否存在
/// 
/// # 参数
/// - `file_path`: 文件路径
/// 
/// # 返回值
/// 如果文件存在返回 true，否则返回 false
pub async fn file_exists(file_path : String) -> Bool noraise {
  try {
    let file = @fs.open(file_path.to_ascii(), mode=ReadOnly)
    file.close()
    true
  } catch {
    _ => false
  }
}

///| 获取文件信息
/// 
/// # 参数
/// - `file_path`: 文件路径
/// 
/// # 返回值
/// 包含文件大小和类型的元组
pub async fn get_file_info(file_path : String) -> (Int64, String) raise {
  let file = @fs.open(file_path.to_ascii(), mode=ReadOnly)
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

///| 异步读取目录内容
/// 
/// # 参数
/// - `dir_path`: 目录路径
/// 
/// # 返回值
/// 目录中文件名的数组
pub async fn read_directory(dir_path : String) -> Array[String] raise {
  let dir_file = @fs.open(dir_path.to_ascii(), mode=ReadOnly)
  defer dir_file.close()
  let dir = dir_file.as_dir()
  let files = dir.read_all()
  let mut result = Array::new()
  for file in files {
    result.push(ascii_to_string(file))
  }
  result
}

///| 查找目录中的所有 .env 文件
/// 
/// # 参数
/// - `dir_path`: 目录路径
/// 
/// # 返回值
/// .env 文件路径的数组
pub async fn find_env_files(dir_path : String) -> Array[String] raise {
  let files = read_directory(dir_path)
  let mut env_files = Array::new()
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
