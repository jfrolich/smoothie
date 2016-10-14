defmodule Mailer do
  use Smoothie,
    template_dir: Path.join(["data", "templates"]),
    layout_file: Path.join(["data", "templates", "layout", "layout.html.eex"]),
    scss_file: Path.join(["data", "templates", "layout", "style.scss"])
end

defmodule SmoothieTest do
  use ExUnit.Case
  doctest Smoothie

  module_paths = [
      __ENV__.file,
      Path.join(["test", "data", "scss", "mailer.ex"]),
      Path.join(["test", "data", "css", "mailer.ex"]),
      Path.join(["test", "data", "foundation", "mailer.ex"])
    ]

#  @base_path Path.join([Path.dirname(__ENV__.file), "templates"])

  for module_path <- module_paths do
    Module.register_attribute(__MODULE__, :base_path, accumulate: false, persist: false)
    @base_path Path.join([Path.dirname(module_path), "templates"])

    setup do
      File.rm(Path.join([@base_path, "build", "welcome.html.eex"]))
      File.rm(Path.join([@base_path, "build", "welcome.txt.eex"]))
      [base_path: @base_path]
    end

    test "producing correct snapshots for #{module_path}", context do
      Mix.Tasks.Smoothie.Compile.run([])

      actual_html = File.read!(Path.join([context.base_path, "build", "welcome.html.eex"]))
      expected_html = File.read!(Path.join([context.base_path, "snapshots", "welcome.html.eex"]))

      actual_text = File.read!(Path.join([context.base_path, "build", "welcome.txt.eex"]))
      expected_text = File.read!(Path.join([context.base_path, "snapshots", "welcome.txt.eex"]))

      assert(actual_html == expected_html)
      assert(actual_text == expected_text)
    end
  end

end
