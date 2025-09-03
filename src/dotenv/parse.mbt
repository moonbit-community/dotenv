///| Dotenv parsing module for MoonBit

///|

///| This module provides functionality to parse .env file content into a Map.

///| It handles various formats including quoted values, comments, and variable expansion.

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

///| Find the index of a substring in a string
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

///| Expand variables in unquoted values, supporting $VAR and ${VAR} and ${VAR:-default} syntax
fn expand_variables(
  str : String,
  variables_map : Map[String, String],
) -> String {
  let mut result = ""
  let mut i = 0
  while i < str.length() {
    if str[i] == 36 { // '$' = 36
      // Check for escaped dollar sign
      if i > 0 && str[i - 1] == 92 { // '\' = 92
        // Remove the escape character and add the dollar sign
        result = result.substring(start=0, end=result.length() - 1) + "$"
        i = i + 1
        continue
      }
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
          let var_expr = str.substring(start=i + 2, end=j - 1)
          let expanded = expand_variable_expression(var_expr, variables_map)
          result = result + expanded
          i = j
        } else {
          // Unmatched brace, treat as literal
          result = result + "$"
          i = i + 1
        }
      } else if i + 1 < str.length() && is_var_start_char(str[i + 1]) {
        // Handle $VAR syntax
        let mut j = i + 1
        while j < str.length() && is_var_char(str[j]) {
          j = j + 1
        }
        let var_name = str.substring(start=i + 1, end=j)
        let value = get_variable_value(var_name, variables_map)
        result = result + value
        i = j
      } else {
        // Dollar sign not followed by valid variable, treat as literal
        result = result + "$"
        i = i + 1
      }
    } else {
      result = result + str.substring(start=i, end=i + 1)
      i = i + 1
    }
  }
  result
}

///| Expand a variable expression (contents inside ${})
fn expand_variable_expression(
  expr : String,
  variables_map : Map[String, String],
) -> String {
  // Check for default value syntax: VAR:-default
  match index_of_substring(expr, ":-") {
    Some(pos) => {
      let var_name = expr.substring(start=0, end=pos)
      let default_value = expr.substring(start=pos + 2)
      let expanded_default = expand_variables(default_value, variables_map)
      match variables_map.get(var_name) {
        Some(value) => value
        None => expanded_default
      }
    }
    None => get_variable_value(expr, variables_map)
  }
}

///| Get the value of a variable, checking both the variables map and simulated environment
fn get_variable_value(
  var_name : String,
  variables_map : Map[String, String],
) -> String {
  match variables_map.get(var_name) {
    Some(value) => value
    None => "" // In a real implementation, this would check Deno.env.get(var_name)
  }
}

///| Check if a character can start a variable name
fn is_var_start_char(ch : Int) -> Bool {
  is_alpha(ch) || ch == 95 // letter or underscore
}

///| Check if a character can be part of a variable name
fn is_var_char(ch : Int) -> Bool {
  is_alnum(ch) || ch == 95 // letter, digit, or underscore
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
fn parse_value(value_part : String) -> (String, Bool) {
  let trimmed = trim_string(value_part)

  // Handle single quotes - no interpolation
  if starts_with(trimmed, "'") &&
    ends_with(trimmed, "'") &&
    trimmed.length() >= 2 {
    let content = trimmed.substring(start=1, end=trimmed.length() - 1)
    return (content, false)
  }

  // Handle double quotes - with interpolation
  if starts_with(trimmed, "\"") &&
    ends_with(trimmed, "\"") &&
    trimmed.length() >= 2 {
    let content = trimmed.substring(start=1, end=trimmed.length() - 1)
    return (expand_characters(content), false)
  }

  // Unquoted value - trim and handle comments
  let value = match index_of_char(trimmed, 35) { // '#' = 35
    Some(pos) => trim_string(trimmed.substring(start=0, end=pos))
    None => trimmed
  }
  (value, true) // true indicates this is unquoted and needs variable expansion
}

///| Parse a single line and extract key-value pair
fn parse_line(line : String) -> (String, String, Bool)? {
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
      let (value, needs_expansion) = parse_value(value_part)
      Some((key, value, needs_expansion))
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
  let keys_for_expand_check : Array[String] = []
  let lines = text.split("\n")

  // First pass: parse all lines and collect keys that need expansion
  for line_view in lines {
    let line = line_view.to_string() // Convert StringView to String
    match parse_line(line) {
      Some((key, value, needs_expansion)) => {
        env[key] = value
        if needs_expansion {
          keys_for_expand_check.push(key)
        }
      }
      None => continue
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
