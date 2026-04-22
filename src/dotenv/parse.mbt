///| Dotenv parsing module for MoonBit

///|

///| This module provides functionality to parse .env file content into a Map.

///| It handles various formats including quoted values, comments, and variable expansion.

///|
/// Helper function to trim whitespace from both ends of a string
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
    str[start:end].to_string()
  }
}

///|
/// Check if a character (as UTF-16 code unit) is whitespace
fn is_whitespace(ch : UInt16) -> Bool {
  ch == 32 || ch == 9 || ch == 13 || ch == 10 // space, tab, CR, LF
}

///|
/// Find the index of a character in a string
fn index_of_char(str : String, ch : UInt16) -> Int? {
  for i = 0; i < str.length(); i = i + 1 {
    if str[i] == ch {
      return Some(i)
    }
  }
  None
}

///|
/// Find the index of a substring in a string
fn index_of_substring(str : String, substr : String) -> Int? {
  if substr.length() == 0 {
    return Some(0)
  }
  for i = 0; i <= str.length() - substr.length(); i = i + 1 {
    let mut found = true
    for j = 0; j < substr.length(); j = j + 1 {
      if str[i + j] != substr[j] {
        found = false
        break
      }
    }
    if found {
      return Some(i)
    }
  }
  None
}

///|
/// Expand escape characters in a string
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
          result = result + str[i:i + 1].to_string()
          i = i + 1
        }
      }
    } else {
      result = result + str[i:i + 1].to_string()
      i = i + 1
    }
  }
  result
}

///|
/// Expand variables in unquoted values, supporting $VAR and ${VAR} and ${VAR:-default} syntax
fn expand_variables(
  str : String,
  variables_map : Map[String, String],
) -> String {
  let mut result = ""
  let mut i = 0
  while i < str.length() {
    if str[i] == 92 && i + 1 < str.length() && str[i + 1] == 36 { // \$ = escaped dollar
      // Handle escaped dollar sign - add literal $ and skip the escape
      result = result + "$"
      i = i + 2
      continue
    } else if str[i] == 36 { // '$' = 36
      if i + 1 < str.length() && str[i + 1] == 123 { // '{' = 123
        // Handle ${VAR} or ${VAR:-default} syntax
        let mut j = i + 2
        let mut depth = 1
        while j < str.length() && depth > 0 {
          if str[j] == 123 { // '{'
            depth = depth + 1
          } else if str[j] == 125 { // '}'
            depth = depth - 1
          }
          j = j + 1
        }
        if depth == 0 {
          let var_expr = str[i + 2:j - 1].to_string()
          let expanded = expand_variable_expression(var_expr, variables_map)
          result = result + expanded
          i = j
        } else {
          // Unmatched brace, treat as literal
          result = result + "$"
          i = i + 1
        }
      } else if i + 1 < str.length() && is_var_start_char(str[i + 1]) {
        // Handle $VAR syntax - check for default value syntax VAR:-default
        let mut j = i + 1
        while j < str.length() && is_var_char(str[j]) {
          j = j + 1
        }

        // Check if this is followed by :-default syntax
        if j + 1 < str.length() && str[j] == 58 && str[j + 1] == 45 { // ':' = 58, '-' = 45
          // Find the end of the default value (space, newline, or end of string)
          let mut k = j + 2
          while k < str.length() && str[k] != 32 && str[k] != 10 && str[k] != 13 {
            k = k + 1
          }
          let var_name = str[i + 1:j].to_string()
          let default_value = str[j + 2:k].to_string()
          let expanded_default = expand_variables(default_value, variables_map)
          match variables_map.get(var_name) {
            Some(value) => result = result + value
            None => result = result + expanded_default
          }
          i = k
        } else {
          let var_name = str[i + 1:j].to_string()
          let value = get_variable_value(var_name, variables_map)
          result = result + value
          i = j
        }
      } else {
        // Dollar sign not followed by valid variable, treat as literal
        result = result + "$"
        i = i + 1
      }
    } else {
      result = result + str[i:i + 1].to_string()
      i = i + 1
    }
  }
  result
}

///|
/// Expand a variable expression (contents inside ${})
fn expand_variable_expression(
  expr : String,
  variables_map : Map[String, String],
) -> String {
  // Check for default value syntax: VAR:-default
  match index_of_substring(expr, ":-") {
    Some(pos) => {
      let var_name = expr[:pos].to_string()
      let default_value = expr[pos + 2:].to_string()
      let expanded_default = expand_variables(default_value, variables_map)
      match variables_map.get(var_name) {
        Some(value) => value
        None => expanded_default
      }
    }
    None => get_variable_value(expr, variables_map)
  }
}

///|
/// Get the value of a variable, checking both the variables map and simulated environment
fn get_variable_value(
  var_name : String,
  variables_map : Map[String, String],
) -> String {
  match variables_map.get(var_name) {
    Some(value) => value
    None => "" // In a real implementation, this would check Deno.env.get(var_name)
  }
}

///|
/// Check if a character can start a variable name
fn is_var_start_char(ch : UInt16) -> Bool {
  is_alpha(ch) || ch == 95 // letter or underscore
}

///|
/// Check if a character can be part of a variable name
fn is_var_char(ch : UInt16) -> Bool {
  is_alnum(ch) || ch == 95 // letter, digit, or underscore
}

///|
/// Check if key matches valid identifier pattern
fn is_valid_key(key : String) -> Bool {
  if key.length() == 0 {
    return false
  }
  let first = key[0]
  if !(is_alpha(first) || first == 95) { // '_' = 95
    return false
  }
  for i = 1; i < key.length(); i = i + 1 {
    let c = key[i]
    if !(is_alnum(c) || c == 95) { // '_' = 95
      return false
    }
  }
  true
}

///|
/// Check if character (as UTF-16 code unit) is alphabetic
fn is_alpha(ch : UInt16) -> Bool {
  (ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122) // A-Z or a-z
}

///|
/// Check if character (as UTF-16 code unit) is alphanumeric
fn is_alnum(ch : UInt16) -> Bool {
  is_alpha(ch) || (ch >= 48 && ch <= 57) // 0-9
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

///|
/// @returns The parsed environment variables as a Map
pub fn parse(text : String) -> Map[String, String] {
  let env : Map[String, String] = Map::new()
  let keys_for_expand_check : Array[String] = []

  // Parse the entire text character by character to handle multiline values
  let mut i = 0
  while i < text.length() {
    // Skip whitespace and empty lines
    while i < text.length() && is_whitespace(text[i]) {
      i = i + 1
    }
    if i >= text.length() {
      break
    }

    // Skip comments
    if text[i] == 35 { // '#' = 35
      // Skip to end of line
      while i < text.length() && text[i] != 10 { // '\n' = 10
        i = i + 1
      }
      continue
    }

    // Parse key-value pair
    match parse_kv_pair(text, i) {
      Some((key, value, needs_expansion, next_pos)) => {
        if is_valid_key(key) {
          env[key] = value
          if needs_expansion {
            keys_for_expand_check.push(key)
          }
        } else {
          println(
            "Warning: Ignored the key \"\{key}\" as it is not a valid identifier",
          )
        }
        i = next_pos
      }
      None => {
        // Skip to next line if we can't parse this line
        while i < text.length() && text[i] != 10 { // '\n' = 10
          i = i + 1
        }
        if i < text.length() {
          i = i + 1 // Skip the newline
        }
      }
    }
  }

  // Second pass: expand variables in unquoted values
  let variables_map : Map[String, String] = Map::new()
  for entry in env {
    let (key, value) = entry
    variables_map[key] = value
  }
  for key in keys_for_expand_check {
    match env.get(key) {
      Some(value) => {
        let expanded_value = expand_variables(value, variables_map)
        env[key] = expanded_value
        variables_map[key] = expanded_value // Update the map with expanded value
      }
      None => continue
    }
  }
  env
}

///|
/// Parse a key-value pair starting at position i
fn parse_kv_pair(
  text : String,
  start_pos : Int,
) -> (String, String, Bool, Int)? {
  let mut i = start_pos

  // Skip export prefix
  if i + 7 < text.length() && text[i:i + 7].to_string() == "export " {
    i = i + 7
    while i < text.length() && is_whitespace(text[i]) {
      i = i + 1
    }
  }

  // Parse key
  let key_start = i
  while i < text.length() && is_var_char(text[i]) {
    i = i + 1
  }
  if i == key_start {
    return None // No key found
  }
  let key = text[key_start:i].to_string()

  // Skip whitespace
  while i < text.length() && (text[i] == 32 || text[i] == 9) { // space or tab
    i = i + 1
  }

  // Expect '='
  if i >= text.length() || text[i] != 61 { // '=' = 61
    return None
  }
  i = i + 1

  // Skip whitespace after =
  while i < text.length() && (text[i] == 32 || text[i] == 9) { // space or tab
    i = i + 1
  }

  // Parse value
  if i >= text.length() {
    return Some((key, "", true, i))
  }
  match parse_value_at_pos(text, i) {
    Some((value, needs_expansion, next_pos)) =>
      Some((key, value, needs_expansion, next_pos))
    None => None
  }
}

///|
/// Parse value starting at position i, handling quotes and multiline
fn parse_value_at_pos(text : String, start_pos : Int) -> (String, Bool, Int)? {
  let mut i = start_pos
  if i >= text.length() {
    return Some(("", true, i))
  }

  // Handle single quotes (including multiline)
  if text[i] == 39 { // '\'' = 39
    i = i + 1
    let mut content = ""

    // Find closing quote, allowing for newlines
    while i < text.length() && text[i] != 39 {
      content = content + text[i:i + 1].to_string()
      i = i + 1
    }
    if i >= text.length() {
      return None // Unclosed quote
    }
    i = i + 1 // Skip closing quote

    // Skip to end of line or find next non-whitespace
    while i < text.length() && (text[i] == 32 || text[i] == 9) { // space or tab
      i = i + 1
    }
    // Skip past comments
    if i < text.length() && text[i] == 35 { // '#'
      while i < text.length() && text[i] != 10 && text[i] != 13 {
        i = i + 1
      }
    }
    // Skip line ending
    if i < text.length() &&
      text[i] == 13 &&
      i + 1 < text.length() &&
      text[i + 1] == 10 {
      i = i + 2 // Skip \r\n
    } else if i < text.length() && (text[i] == 10 || text[i] == 13) {
      i = i + 1 // Skip \n or \r
    }
    return Some((content, false, i)) // Single quotes don't expand variables
  }

  // Handle double quotes (including multiline)
  if text[i] == 34 { // '\"' = 34
    i = i + 1
    let mut content = ""

    // Find closing quote, allowing for newlines and escaped quotes
    while i < text.length() && text[i] != 34 {
      if text[i] == 92 && i + 1 < text.length() && text[i + 1] == 34 { // Escaped quote \"
        content = content + "\""
        i = i + 2
      } else {
        content = content + text[i:i + 1].to_string()
        i = i + 1
      }
    }
    if i >= text.length() {
      return None // Unclosed quote
    }
    let expanded_content = expand_characters(content)
    i = i + 1 // Skip closing quote

    // Skip to end of line or find next non-whitespace
    while i < text.length() && (text[i] == 32 || text[i] == 9) { // space or tab
      i = i + 1
    }
    // Skip past comments
    if i < text.length() && text[i] == 35 { // '#'
      while i < text.length() && text[i] != 10 && text[i] != 13 {
        i = i + 1
      }
    }
    // Skip line ending
    if i < text.length() &&
      text[i] == 13 &&
      i + 1 < text.length() &&
      text[i + 1] == 10 {
      i = i + 2 // Skip \r\n
    } else if i < text.length() && (text[i] == 10 || text[i] == 13) {
      i = i + 1 // Skip \n or \r
    }
    return Some((expanded_content, true, i)) // Double quotes expand variables
  }

  // Handle unquoted value
  let value_start = i
  while i < text.length() && text[i] != 10 && text[i] != 13 && text[i] != 35 { // not newline or #
    i = i + 1
  }
  let mut value = text[value_start:i].to_string()

  // Handle inline comments
  match index_of_char(value, 35) { // '#' = 35
    Some(pos) => value = value[:pos].to_string()
    None => ()
  }
  value = trim_string(value)

  // Skip to end of line
  while i < text.length() && text[i] != 10 && text[i] != 13 { // '\n' = 10, '\r' = 13
    i = i + 1
  }
  if i < text.length() &&
    text[i] == 13 &&
    i + 1 < text.length() &&
    text[i + 1] == 10 {
    i = i + 2 // Skip \r\n
  } else if i < text.length() && (text[i] == 10 || text[i] == 13) {
    i = i + 1 // Skip \n or \r
  }
  Some((value, true, i)) // Unquoted values expand variables
}
