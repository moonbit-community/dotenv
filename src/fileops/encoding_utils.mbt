///| Shared encoding utilities for fileops package
///
/// This module provides common UTF-8 encoding/decoding functions
/// used throughout the fileops package.

///|
/// 将 String 转换为 UTF-8 Bytes
pub fn string_to_utf8_bytes(str : String) -> Bytes {
  @encoding.encode(str, encoding=UTF8)
}

///|
/// 将 UTF-8 Bytes 转换为 String
pub fn utf8_bytes_to_string(bytes : BytesView) -> String {
  @encoding.decode(bytes, encoding=UTF8) catch {
    _ => {
      // Fallback to ASCII conversion if UTF-8 decode fails
      let builder = StringBuilder::new()
      for byte in bytes {
        builder.write_char(byte.to_int().unsafe_to_char())
      }
      builder.to_string()
    }
  }
}
