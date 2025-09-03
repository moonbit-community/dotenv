///| 异步文件写入器
///
/// 提供异步文件写入功能，特别针对 .env 文件的写入和备份操作
suberror DirectoryError String

///| 异步写入文件内容
/// 
/// # 参数
/// - `file_path`: 文件路径
/// - `content`: 要写入的内容
/// - `permission`: 文件权限（默认 0o644）
/// 
/// # 错误
/// 如果写入失败会抛出异常
pub async fn write_file_content(
  file_path : String,
  content : String,
  permission? : Int = 0o644,
) -> Unit raise {
  let file = @fs.create(file_path.to_ascii(), permission~, sync=Full)
  defer file.close()
  file.write(content.to_ascii())
}

///| 异步写入 .env 文件
/// 
/// # 参数
/// - `env_file_path`: .env 文件路径
/// - `env_vars`: 环境变量 Map
/// - `permission`: 文件权限（默认 0o644）
/// 
/// # 错误
/// 如果写入失败会抛出异常
pub async fn write_env_file(
  env_file_path : String,
  env_vars : Map[String, String],
  permission? : Int = 0o644,
) -> Unit raise {
  let content = @dotenv.stringify(env_vars)
  write_file_content(env_file_path, content, permission~)
}

///| 安全地写入 .env 文件（先备份原文件）
/// 
/// # 参数
/// - `env_file_path`: .env 文件路径
/// - `env_vars`: 环境变量 Map
/// - `backup_suffix`: 备份文件后缀（默认 ".backup"）
/// 
/// # 错误
/// 如果操作失败会抛出异常
pub async fn write_env_file_safe(
  env_file_path : String,
  env_vars : Map[String, String],
  backup_suffix? : String = ".backup",
) -> Unit raise {
  let backup_path = env_file_path + backup_suffix

  // 如果原文件存在，先创建备份
  if file_exists(env_file_path) {
    let original_content = read_file_content(env_file_path)
    write_file_content(backup_path, original_content)
  }

  // 写入新内容
  write_env_file(env_file_path, env_vars) catch {
    err => {
      // 如果写入失败且存在备份，尝试恢复
      if file_exists(backup_path) {
        let backup_content = read_file_content(backup_path)
        write_file_content(env_file_path, backup_content)
      }
      raise err
    }
  }
}

///| 追加内容到文件
/// 
/// # 参数
/// - `file_path`: 文件路径
/// - `content`: 要追加的内容
/// 
/// # 错误
/// 如果操作失败会抛出异常
pub async fn append_file_content(
  file_path : String,
  content : String,
) -> Unit raise {
  let file = @fs.open(
    file_path.to_ascii(),
    mode=WriteOnly,
    append=true,
    create=0o644,
  )
  defer file.close()
  file.write(content.to_ascii())
}

///| 创建目录（如果不存在）
/// 
/// # 参数
/// - `dir_path`: 目录路径
/// 
/// # 注意
/// 这是一个简化实现，实际项目中可能需要递归创建父目录
pub async fn ensure_directory(dir_path : String) -> Unit raise DirectoryError {
  // 简单检查目录是否存在
  let exists = try {
    let dir_file = @fs.open(dir_path.to_ascii(), mode=ReadOnly)
    defer dir_file.close()
    match dir_file.kind() {
      Directory => true
      _ => false
    }
  } catch {
    _ => false
  }
  if not(exists) {
    // 注意：这里只是演示，实际的目录创建需要系统调用
    // 在真实项目中，你可能需要使用 @process.run 来调用 mkdir
    raise DirectoryError(
      "Directory creation not implemented - use system mkdir command",
    )
  }
}

///| 删除文件
/// 
/// # 参数
/// - `file_path`: 文件路径
/// 
/// # 错误
/// 如果删除失败会抛出异常
pub async fn delete_file(file_path : String) -> Unit raise {
  @fs.remove(file_path.to_ascii())
}

///| 复制文件
/// 
/// # 参数
/// - `source_path`: 源文件路径
/// - `dest_path`: 目标文件路径
/// 
/// # 错误
/// 如果复制失败会抛出异常
pub async fn copy_file(source_path : String, dest_path : String) -> Unit raise {
  let content = read_file_content(source_path)
  write_file_content(dest_path, content)
}
