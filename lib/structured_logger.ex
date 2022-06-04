defmodule StructuredLogger do
  @moduledoc """
  A logger formatter focused on structured logging.
  """

  alias StructuredLogger.ValueMapper

  @config Application.get_env(:structured_logger, :metadata, [])

  @default_exclude [
    :erl_level,
    :application,
    :file,
    :function,
    :gl,
    :line,
    :mfa,
    :module,
    :pid,
    ~r/secret/,
    ~r/password/,
    ~r/token/,
    ~r/cookie/,
    ~r/crypt/
  ]

  @exclude_clauses (case Keyword.fetch(@config, :only_exclude) do
                      {:ok, exclude} ->
                        exclude

                      _ ->
                        also_exclude = Keyword.get(@config, :also_exclude, [])
                        also_exclude ++ @default_exclude
                    end)

  @simple_exclude Enum.filter(@exclude_clauses, &is_atom/1)
  @regex_exclude Enum.filter(@exclude_clauses, &match?(%Regex{}, &1))

  @doc """
  Receives the description of a log and outputs a string with a formatted log

  ### Parameters
    - level: The logging level that describes how critical is this log message
    - message: An iodata with the actual log message
    - timestamp: A tuple representing the log timestamp
    - metadata: A Keyword list with additional metadata related to the log
  """
  @spec format(atom(), String.t(), tuple(), Keyword.t()) :: String.t()
  def format(level, message, _timestamp, metadata) do
    log =
      [{:level, level}, {:msg, IO.iodata_to_binary(message)} | metadata]
      |> transform_stacktrace()
      |> exclude_metadata()
      |> transform_values()
      |> Logfmt.encode()

    log <> "\n"
  end

  @spec transform_stacktrace(Keyword.t()) :: Keyword.t()
  defp transform_stacktrace(metadata) do
    case Keyword.fetch(metadata, :stacktrace) do
      {:ok, stacktrace} when is_list(stacktrace) ->
        Keyword.put(metadata, :stacktrace, try_format_stacktrace(stacktrace))

      _ ->
        metadata
    end
  end

  defp try_format_stacktrace(stacktrace) do
    Exception.format_stacktrace(stacktrace)
  rescue
    _ -> stacktrace
  end

  @spec exclude_metadata(Keyword.t()) :: Keyword.t()
  defp exclude_metadata(metadata) do
    metadata
    |> Keyword.drop(@simple_exclude)
    |> Keyword.filter(fn {key, _value} ->
      key = to_string(key)
      not Enum.any?(@regex_exclude, &Regex.match?(&1, key))
    end)
  end

  @spec transform_values(Keyword.t()) :: [{binary() | atom(), term()}]
  defp transform_values(metadata) do
    Enum.flat_map(metadata, &transform_value/1)
  end

  defp transform_value({key, value}) do
    case ValueMapper.map(value) do
      {:ok, complex} when is_map(complex) or is_list(complex) ->
        for {subkey, value} <- complex do
          {"#{key}.#{subkey}", value}
        end

      {:ok, primitive} ->
        [{key, primitive}]

      :ignore ->
        []
    end
  end
end
