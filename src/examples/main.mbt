///|
/// Demo function demonstrating dotenv and fileops functionality
pub fn run_demo() -> Unit {
  println("=== MoonBit Dotenv & FileOps Demo ===")

  // Demo the dotenv functionality
  println("\n--- Dotenv Functionality ---")
  demo_all_features()

  // Demo async functionality
  println("\n--- Async File Operations ---")
  @async.with_event_loop(async fn(_) { demo_async_features() }) catch {
    err => println("Async demo error: \{err}")
  }
  println("\n=== Demo Complete ===")
}
