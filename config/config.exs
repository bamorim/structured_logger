import Config

if config_env() == :test do
  config :structured_logger,
    metadata: [
      also_exclude: [:excluded_key, ~r/^my_key/]
    ]
end
