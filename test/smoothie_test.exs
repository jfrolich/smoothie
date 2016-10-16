defmodule SmoothieTest do
  use ExUnit.Case
  doctest Smoothie

  @module_paths [
      Path.join([Path.dirname(__ENV__.file), "data", "scss", "mailer.ex"]),
      Path.join([Path.dirname(__ENV__.file),  "data", "css", "mailer.ex"]),
      Path.join([Path.dirname(__ENV__.file),  "data", "foundation", "mailer.ex"])
    ]

  setup_all do
    @module_paths
    |> Enum.map(&(Path.join([Path.dirname(&1), "build"])))
    |> Enum.each(&File.rm_rf!/1)
    Mix.Tasks.Smoothie.Compile.run([])
  end

  for module_path <- @module_paths do
    Module.register_attribute(__MODULE__, :base_path, accumulate: false, persist: false)
    Module.register_attribute(__MODULE__, :module, accumulate: false, persist: false)
    @base_path Path.join([Path.dirname(module_path), "templates"])
    @module Code.eval_file(module_path)
      |> Tuple.to_list()
      |> List.first()
      |> Tuple.to_list()
      |> List.delete_at(0)
      |> List.first()

    test "producing correct snapshots for #{@module}" do
      actual_html = File.read!(Path.join([@base_path, "build", "welcome.html.eex"]))
      expected_html = File.read!(Path.join([@base_path, "snapshots", "unassigned", "welcome.html.eex"]))
      actual_text = File.read!(Path.join([@base_path, "build", "welcome.txt.eex"]))
      expected_text = File.read!(Path.join([@base_path, "snapshots", "unassigned", "welcome.txt.eex"]))

      assert(actual_html == expected_html)
      assert(actual_text == expected_text)
    end

    test "producing correct snapshots for #{@module} after variable injection" do
      actual_html = @module.html()
      expected_html = File.read!(Path.join([@base_path, "snapshots", "assigned", "welcome.html"]))
      actual_text = @module.text()
      expected_text = File.read!(Path.join([@base_path, "snapshots", "assigned", "welcome.txt"]))

      assert(actual_html == expected_html)
      assert(actual_text == expected_text)
    end
  end

end
