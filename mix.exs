defmodule Smoothie.Mixfile do
  use Mix.Project

  def project do
    [
      app: :smoothie,
      version: "1.0.1",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: """
      Inline styling and plain text template generation for your email templates.
      """,
      deps: deps(),
      package: package(),
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
      maintainers: ["Jaap Frölich"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/jfrolich/smoothie"},
      files: ~w(lib mix.exs README.md),
    ]
  end
end
