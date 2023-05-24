defmodule StructuredLogger.MixProject do
  use Mix.Project

  @source_url "https://github.com/bamorim/structured_logger"

  def project do
    [
      app: :structured_logger,
      version: "0.0.1",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Logger formatter focused on structured logs",
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix, :credo]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      name: "StructuredLogger",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: [
        # The main page in the docs
        main: "StructuredLogger",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:logfmt, "~> 3.3"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:doctor, "~> 0.18.0", only: :dev, runtime: false},
      {:ex_check, "~> 0.14.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:mock, "~> 0.3.7", only: [:dev, :test]},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  defp package do
    [
      name: "structured_logger",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
