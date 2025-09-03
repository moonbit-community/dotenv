///| Dotenv parsing module for MoonBit

///|

///| This module provides functionality to parse .env file content into a Map.

///| It handles various formats including quoted values and comments.

///| Helper function to trim whitespace from both ends of a string
fn trim_string(str : String) -> String {
  let mut start = 0
  let mut end = str.length()

  // Trim leading whitespace
  while start < end && is_whitespace(str[start]) {
    start = start + 1
  }

  // Trim trailing whitespace
  while end > start && is_whitespace(str[end - 1]) {
    end = end - 1
  }
  if start == 0 && end == str.length() {
    str
  } else {
    str.substring(start~, end~)
  }
}

///| Check if a character (as Int codepoint) is whitespace
fn is_whitespace(ch : Int) -> Bool {
  ch == 32 || ch == 9 || ch == 13 || ch == 10 // space, tab, CR, LF
}

///| Check if a string starts with a prefix
fn starts_with(str : String, prefix : String) -> Bool {
  if prefix.length() > str.length() {
    return false
  }
  for i = 0; i < prefix.length(); i = i + 1 {
    if str[i] != prefix[i] {
      return false
    }
  }
  true
}

///| Check if a string ends with a suffix
fn ends_with(str : String, suffix : String) -> Bool {
  if suffix.length() > str.length() {
    return false
  }
  let offset = str.length() - suffix.length()
  for i = 0; i < suffix.length(); i = i + 1 {
    if str[offset + i] != suffix[i] {
      return false
    }
  }
  true
}

///| Find the index of a character in a string
fn index_of_char(str : String, ch : Int) -> Int? {
  for i = 0; i < str.length(); i = i + 1 {
    if str[i] == ch {
      return Some(i)
    }
  }
  None
}

///| Expand escape characters in a string
fn expand_characters(str : String) -> String {
  let mut result = ""
  let mut i = 0
  while i < str.length() {
    if str[i] == 92 && i + 1 < str.length() { // backslash = 92
      match str[i + 1] {
        110 => { // 'n' = 110
          result = result + "\n"
          i = i + 2
        }
        114 => { // 'r' = 114
          result = result + "\r"
          i = i + 2
        }
        116 => { // 't' = 116
          result = result + "\t"
          i = i + 2
        }
        _ => {
          result = result + str.substring(start=i, end=i + 1)
          i = i + 1
        }
      }
    } else {
      result = result + str.substring(start=i, end=i + 1)
      i = i + 1
    }
  }
  result
}

///| Check if key matches valid identifier pattern
fn is_valid_key(key : String) -> Bool {
  if key.length() == 0 {
    return false
  }
  let first = key[0]
  if not(is_alpha(first) || first == 95) { // '_' = 95
    return false
  }
  for i = 1; i < key.length(); i = i + 1 {
    let c = key[i]
    if not(is_alnum(c) || c == 95) { // '_' = 95
      return false
    }
  }
  true
}

///| Check if character (as Int codepoint) is alphabetic
fn is_alpha(ch : Int) -> Bool {
  (ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122) // A-Z or a-z
}

///| Check if character (as Int codepoint) is alphanumeric
fn is_alnum(ch : Int) -> Bool {
  is_alpha(ch) || (ch >= 48 && ch <= 57) // 0-9
}

///| Parse the value part of a key-value pair, handling quotes and escapes
fn parse_value(value_part : String) -> String {
  let trimmed = trim_string(value_part)

  // Handle single quotes - no interpolation
  if starts_with(trimmed, "'") &&
    ends_with(trimmed, "'") &&
    trimmed.length() >= 2 {
    return trimmed.substring(start=1, end=trimmed.length() - 1)
  }

  // Handle double quotes - with interpolation
  if starts_with(trimmed, "\"") &&
    ends_with(trimmed, "\"") &&
    trimmed.length() >= 2 {
    let content = trimmed.substring(start=1, end=trimmed.length() - 1)
    return expand_characters(content)
  }

  // Unquoted value - trim and handle comments
  match index_of_char(trimmed, 35) { // '#' = 35
    Some(pos) => trim_string(trimmed.substring(start=0, end=pos))
    None => trimmed
  }
}

///| Parse a single line and extract key-value pair
fn parse_line(line : String) -> (String, String)? {
  let trimmed = trim_string(line)

  // Skip empty lines and comments
  if trimmed == "" || starts_with(trimmed, "#") {
    return None
  }

  // Skip export prefix
  let working_line = if starts_with(trimmed, "export ") {
    trim_string(trimmed.substring(start=7))
  } else {
    trimmed
  }

  // Find the first = sign
  match index_of_char(working_line, 61) { // '=' = 61
    Some(eq_pos) => {
      let key = trim_string(working_line.substring(start=0, end=eq_pos))
      let value_part = working_line.substring(start=eq_pos + 1)

      // Validate key format
      if not(is_valid_key(key)) {
        println(
          "Warning: Ignored the key \"\{key}\" as it is not a valid identifier",
        )
        return None
      }
      let value = parse_value(value_part)
      Some((key, value))
    }
    None => None
  }
}

///| Parse .env file content into a Map

///|

///| Note: The key needs to match the pattern /^[a-zA-Z_][a-zA-Z0-9_]*$/.

///|

///| @example

///| ```moonbit

///| let env = parse("GREETING=hello world")

///| // Returns: {"GREETING": "hello world"}

///| ```

///|

///| @param text The text to parse

///| @returns The parsed environment variables as a Map
pub fn parse(text : String) -> Map[String, String] {
  let env : Map[String, String] = Map::new()
  let lines = text.split("\n")
  for line_view in lines {
    let line = line_view.to_string() // Convert StringView to String
    match parse_line(line) {
      Some((key, value)) => env[key] = value
      None => continue
    }
  }
  env
}
