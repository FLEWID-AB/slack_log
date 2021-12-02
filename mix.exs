defmodule SlackLog.MixProject do
  use Mix.Project

  @version "0.1.2"

  def project do
    [
      app: :slack_log,
      description: "Simple logger backend that posts notifications to Slack channels",
      version: @version,
      elixir: "~> 1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      source_url: "https://github.com/FLEWID-AB/slack_log",
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: [
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/FLEWID-AB/slack_log",
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

  def package do
    [
      maintainers: ["Julia Will", "Philip Mannheimer"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/FLEWID-AB/slack_log"},
      files: [
        "lib",
        ".formatter.exs",
        "mix.exs",
        "README*",
        "LICENSE*"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, ">= 1.7.0"},
      {:jason, ">= 1.0.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:bypass, "~> 2.1", only: :test},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

end
