- When working with Go files, always use the `golang-how-to` skill and load any
  Go skills discovered from it as they become relevant to the task.
- For any code search that requires understanding of syntax or code structure,
  you should default to using `ast-grep --lang [language] -p '<pattern>'`.
  Adjust the `--lang` flag as needed for the specific programming language.
  Avoid using text-only search tools unless a plain-text search is explicitly
  requested.
