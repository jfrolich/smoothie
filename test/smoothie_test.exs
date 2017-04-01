defmodule SmoothieTest do
  use ExUnit.Case
  doctest Smoothie

  @modules [
    Build.Mailer,
    Scss.Mailer,
    Css.Mailer,
    Foundation.Mailer
  ]

  def clean_build_directories do
    @modules
    |> Enum.map(& &1.__smoothie_template_path__())
    |> Enum.map(&Path.join([&1, "build"]))
    |> Enum.each(&File.rm_rf!/1)
  end

  setup_all do
    clean_build_directories()
    Mix.Tasks.Smoothie.Compile.run([])
    :ok
  end

  def trim(string) do
    string |> String.trim("\n")
  end

  for module <- @modules do
    @module module
    @base_path module.__smoothie_template_path__()

    test "producing correct snapshots for #{@module}" do
      actual_html = File.read!(Path.join([@base_path, "build", "welcome.html.eex"])) |> trim()
      expected_html = File.read!(Path.join([@base_path, "snapshots", "unassigned", "welcome.html.eex"])) |> trim()
      actual_text = File.read!(Path.join([@base_path, "build", "welcome.txt.eex"])) |> trim()
      expected_text = File.read!(Path.join([@base_path, "snapshots", "unassigned", "welcome.txt.eex"])) |> trim()

      assert(actual_html == expected_html)
      assert(actual_text == expected_text)
    end

    test "producing correct snapshots for #{@module} after variable injection" do
      actual_html = @module.html()
      expected_html = File.read!(Path.join([@base_path, "snapshots", "assigned", "welcome.html"]))
      actual_text = @module.text()
      expected_text = File.read!(Path.join([@base_path, "snapshots", "assigned", "welcome.txt"]))

      assert(trim(actual_html) == trim(expected_html))
      assert(trim(actual_text) == trim(expected_text))
    end
  end

end
