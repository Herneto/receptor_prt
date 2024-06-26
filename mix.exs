defmodule ReceptorPRT.MixProject do
  use Mix.Project

  def project do
    [
      app: :receptor_prt,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :logger_file_backend],
      mod: {ReceptorPRT.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:yaml_elixir, "~> 2.9"},
      {:poolboy, "~> 1.5"},
      {:req, "~> 0.4.0"},
      {:logger_file_backend, "~> 0.0.10"},
      {:jason, "~> 1.4"}
    ]
  end
end
