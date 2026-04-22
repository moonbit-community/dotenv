///| Dotenv stringify module for MoonBit

///|

///| This module provides functionality to stringify a Map into .env file format.

///| Check if a string contains newlines
fn contains_newline(str : String) -> Bool {
  for i = 0; i < str.length(); i = i + 1 {
    if str[i] == 10 { // '\n' = 10
      return true
    }
  }
  false
}

///| Check if a string contains single quotes
fn contains_single_quote(str : String) -> Bool {
  for i = 0; i < str.length(); i = i + 1 {
    if str[i] == 39 { // '\'' = 39
      return true
    }
  }
  false
}

///| Check if a string contains non-word characters (excluding alphanumeric and underscore)
fn contains_non_word(str : String) -> Bool {
  for i = 0; i < str.length(); i = i + 1 {
    let ch = str[i]
    if !(is_alnum(ch) || ch == 95) { // '_' = 95
      return true
    }
  }
  false
}

///| Check if character (as Int codepoint) is alphanumeric (using external function)
// This function is defined in parse.mbt and is available in the same package

///| Escape a string by replacing quotes with escaped quotes
fn escape_quotes(str : String, quote : String) -> String {
  let mut result = ""
  let quote_code : UInt16 = if quote == "'" { 39 } else { 34 } // ' or "
  for i = 0; i < str.length(); i = i + 1 {
    if str[i] == quote_code {
      result = result + "\\" + quote
    } else if str[i] == 92 { // backslash
      result = result + "\\\\"
    } else {
      result = result + str[i:i + 1].to_string()
    }
  }
  result
}

///| Escape newlines in a string
fn escape_newlines(str : String) -> String {
  let mut result = ""
  for i = 0; i < str.length(); i = i + 1 {
    if str[i] == 10 { // '\n' = 10
      result = result + "\\n"
    } else if str[i] == 13 { // '\r' = 13
      result = result + "\\r"
    } else {
      result = result + str[i:i + 1].to_string()
    }
  }
  result
}

///| Stringify a Map into a valid .env file format

///|

///| @example

///| ```moonbit

///| let object = Map::new()

///| object["GREETING"] = "hello world"

///| let result = stringify(object)

///| // Returns: "GREETING='hello world'"

///| ```

///|

///| @param object Map to be stringified

///| @returns String representation in .env format
pub fn stringify(object : Map[String, String]) -> String {
  let lines : Array[String] = []
  for entry in object {
    let (key, value) = entry
    let mut quote = ""
    let mut escaped_value = value

    // Skip keys starting with #
    if key.length() > 0 && key[0] == 35 { // '#' = 35
      println(
        "Warning: key starts with a '#' indicates a comment and is ignored: '\{key}'",
      )
      continue
    }

    // Determine quoting and escaping strategy
    if contains_newline(escaped_value) || contains_single_quote(escaped_value) {
      // Use double quotes for multiline or single-quote containing values
      escaped_value = escape_newlines(escaped_value)
      quote = "\""
    } else if contains_non_word(escaped_value) {
      // Use single quotes for values with special characters
      quote = "'"
    }

    // Apply quote escaping if needed
    if quote != "" {
      escaped_value = escape_quotes(escaped_value, quote)
      escaped_value = quote + escaped_value + quote
    }
    let line = key + "=" + escaped_value
    lines.push(line)
  }

  // Convert array to string with newlines
  let mut result = ""
  for i = 0; i < lines.length(); i = i + 1 {
    if i > 0 {
      result = result + "\n"
    }
    result = result + lines[i]
  }
  result
}
