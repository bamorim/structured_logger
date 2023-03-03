defmodule StructWithLogfmt do
  defstruct [:foo, :bar]

  defimpl Logfmt.ValueEncoder do
    def encode(%{foo: foo, bar: bar}), do: "#{foo}/#{bar}"
  end

  defimpl StructuredLogger.ValueMapper do
    def map(data), do: {:ok, data}
  end
end

defmodule StructWithoutLogfmt do
  defstruct [:foo]

  defimpl StructuredLogger.ValueMapper do
    def map(data), do: {:ok, data}
  end
end
