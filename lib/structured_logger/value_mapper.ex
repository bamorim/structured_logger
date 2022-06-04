defprotocol StructuredLogger.ValueMapper do
  @moduledoc """
  As part of the log processing pipeline we transform metadata values to ensure
  we create a flat structure while still keeping important information around.

  This Protocol is responsible for the mapping.

  For each value it can either return

  - `{:ok, term()}`
  - `:ignore`

  If `:ignore` is returned, the value is removed. If `{:ok, term()}` is
  returned, it will depend on the type of the term returned:

  For `atom()`, `binary()`, `integer()`, `pid()` and `reference()` it won't
  change anything

  For a keyword list or a map, it will generate derived metadata using `.` as a
  separator

  For example, for a metadata data with key `:req` and a value that ValueMapper
  implementation returns `%{method: "GET", path: "/posts"}`, it will generate
  `"req.method" => "GET"` and `"req.method" => "/posts"`.

  Nesting is not allowed, this is just a helper for simple cases like the one
  shown above.

  ## Default implementation

  `binary()`, `atom()`, `number()`, `pid()`, `reference()`, `Date`, `DateTime`,
  `NaiveDateTime`, `Time` and `URI` are all kept since these are values that can
  easily be serialized into a simple format.

  ### Exceptions

  By default exceptions (any structure with `__exception__: true`) are converted
  to:

    %{ type: ExceptionType, message: "Exception Message" }

  Where `ExceptionType` is the module and `"Exception Message"` is the
  `Exception.message/1` result.
  """

  @type primitive() :: atom() | binary() | integer() | pid() | reference()
  @type complex() :: %{required(atom() | binary()) => primitive()} | [{atom() | binary(), primitive()}]

  @fallback_to_any true
  @spec map(term()) :: {:ok, primitive() | complex()} | :ignore
  def map(value)
end

defimpl StructuredLogger.ValueMapper, for: Any do
  @simple_values [Date, DateTime, NaiveDateTime, Time, URI]

  def map(%type{__exception__: true} = exception) do
    {:ok, %{
      type: type,
      message: Exception.message(exception)
    }}
  end

  def map(value) when is_atom(value) or is_binary(value) or is_number(value) or is_pid(value) or is_reference(value) do
    {:ok, value}
  end

  def map(%type{} = value) when type in @simple_values do
    {:ok, value}
  end

  def map(_), do: :ignore
end
