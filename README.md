# StructuredLogger

For now this library just provides a simple log formatter to be used alongside the default `:console` backend.

It's goal is to generate a flat key-value structure that is easily serializable in Logfmt (maybe JSON support can be added later). A flat structure is actually a design decision that:

- Makes it easier for humans to read the raw line
- Avoid accidentally leaking complex structures (which can in turn leak sensitive information)
- Allows simpler parsers to work (a simple regex should be able to filter by a given metadata)

The formatting is a pipeline comprised of:

- Starts with the existing metadata
- Adds a `level` metadata based on the log level
- Adds a `msg` metadata with the log message
- Transform complex objects into a collection of keys
  - For example, exceptions can be transformed into `exception.type` and `exception.message`
- Filter specific keys

## Installation

For now this package is only available through git, so to install you can add:

```elixir
def deps do
  [
    {:structured_logger, github: "bamorim/structured_logger"}
  ]
end
```