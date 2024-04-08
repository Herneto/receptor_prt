import Config

{:ok, yaml_content} = ReceptorPRT.Config.load()
{:ok, %{"log_file" => log_file}} = Map.fetch(yaml_content, "logging")
{:ok, %{"log_level" => log_level}} = Map.fetch(yaml_content, "logging")

log_level = log_level |> String.downcase |> String.to_atom

config :logger,
  backends: [{LoggerFileBackend, :app_log}]

config :logger, :app_log, path: log_file, level: log_level
