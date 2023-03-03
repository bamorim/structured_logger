defmodule StructuredLoggerTest do
  use ExUnit.Case

  describe "format/4" do
    test "formats all metadata provided (except configured excluded ones)" do
      assert "level=debug msg=message time=12345 custom_key=custom_data\n" ==
               StructuredLogger.format(:debug, "message", {},
                 time: 12_345,
                 custom_key: "custom_data"
               )
    end

    test "metadata excluded in the config is not present in the logfmt log" do
      assert "level=info msg=message\n" ==
               StructuredLogger.format(:info, "message", {}, excluded_key: :data)
    end

    test "logs stack traces" do
      log_line =
        StructuredLogger.format(:error, "exception", {}, exception: %MatchError{term: :a})

      assert %{
               "level" => "error",
               "exception.type" => "Elixir.MatchError",
               "exception.message" => "no match of right hand side value: :a"
             } = Logfmt.decode(log_line)
    end

    test "it formats a stacktrace" do
      stacktrace = [
        {Map, :filter, 2, [file: 'lib/map.ex', line: 1018]}
      ]

      log_line = StructuredLogger.format(:error, "exception", {}, stacktrace: stacktrace)

      assert %{"stacktrace" => formatted_stacktrace} = Logfmt.decode(log_line)

      assert formatted_stacktrace =~ "lib/map.ex:1018: Map.filter/2"
    end

    test "it doesnt fail with a wrongly formatted :stacktrace key" do
      assert StructuredLogger.format(:error, "message", {}, stacktrace: [:wrong]) =~ "level=error"
    end

    @suspicious_keys [:secret, :password, :token, :cookie, :crypt]
    test "filter keys that are suspiciously secrets by default" do
      for key <- @suspicious_keys do
        r = Enum.random(10..99)

        refute StructuredLogger.format(:error, "message", {}, "#{r}#{key}#{r}": 1) =~
                 to_string(key)
      end
    end

    test "metadata excluded using regex in the config is removed" do
      assert "level=info msg=message keep_my_key=1\n" ==
               StructuredLogger.format(:info, "message", {},
                 excluded_key: :data,
                 keep_my_key: 1,
                 my_key: 2,
                 my_keys: 1
               )
    end

    test "don't flatten struct that implements logfmt protocol" do
      assert "level=info msg=msg mystruct=hello/world\n" ==
               StructuredLogger.format(:info, "msg", {},
                 mystruct: %StructWithLogfmt{foo: "hello", bar: "world"}
               )
    end

    test "flatten struct that don't implement logfmt protocol" do
      assert "level=info msg=msg mystruct.foo=hello\n" ==
               StructuredLogger.format(:info, "msg", {},
                 mystruct: %StructWithoutLogfmt{foo: "hello"}
               )
    end
  end
end
