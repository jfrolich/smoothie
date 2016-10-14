defmodule Scss.Mailer do
  use Smoothie,
    template_dir: Path.join(["templates"]),
    layout_file: Path.join(["templates", "layout", "layout.html.eex"]),
    scss_file: Path.join(["templates", "layout", "style.scss"])
end