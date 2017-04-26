defmodule Smoothie.Mixfile do
  use Mix.Project
    @version "3.1.0"

  def project do
    [
      app: :smoothie,
      version: @version,
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: """
      Stylesheet inlining and plain text template generation for your email templates.
      """,
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env)
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger],
      env: [
        template_dir: Path.join(["web", "mailers", "templates"]),
        layout_dir: Path.join(["web", "mailers", "templates", "layout"])
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      name: :smoothie,
      maintainers: ["Jaap Frölich", "Stephen Moloney"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/jfrolich/smoothie"},
      files: ~w(lib mix.exs README.md),
    ]
  end

  defp elixirc_paths(:test) do
    [
      "lib",
      "test/data/build",
      "test/data/css",
      "test/data/scss",
      "test/data/foundation",
      "test/data/no_compile"
    ]
  end
  defp elixirc_paths(_), do: ["lib"]
end
