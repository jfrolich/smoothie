defmodule Mailer do
  use Smoothie,
    template_dir: Path.join(["data", "templates"]),
    layout_file: Path.join(["data", "templates", "layout", "layout.html.eex"]),
    scss_file: Path.join(["data", "templates", "layout", "style.scss"]),
    use_foundation: true
end

defmodule SmoothieTest do
  use ExUnit.Case
  doctest Smoothie

  test "producing correct snapshots" do
    Mix.Tasks.Smoothie.Compile.run()
    base_path = Path.join([Path.dirname(__ENV__.file), "templates"])
    assert File.open(Path.join([base_path, "build", "welcome.html.eex"])) ==
           File.open(Path.join([base_path, "snapshots", "welcome.html.eex"]))

    assert File.open(Path.join([base_path, "build", "welcome.txt.eex"])) ==
           File.open(Path.join([base_path, "snapshots", "welcome.txt.eex"]))
  end
end
