defmodule Smoothie do
  require EEx

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      require Logger
      require EEx

      @smoothie_path Path.expand(__ENV__.file) |> Path.dirname()
      @use_foundation Keyword.get(opts, :use_foundation, :false)
      @template_dir Keyword.get(opts, :template_dir, :nil)
      @template_build_path Keyword.get(opts, :template_build_dir, Path.join(@template_dir, "build"))
      @layout_file Keyword.get(opts, :layout_file, :nil)
      @scss_file Keyword.get(opts, :scss_file, :nil)
      @css_file Keyword.get(opts, :css_file, :nil)

      File.exists?(@template_dir) || raise("Smoothie: Template path not found: '#{@template_dir}'")
      File.exists?(@template_build_path) || File.mkdir!(@template_build_path)
      File.exists?(@layout_file) || raise("Smoothie: Layout file not found: '#{@layout_file}'")
      @layout_file|| raise("Smoothie: Layout file not found: '#{@layout_file}'")
      @template_files File.ls!(@template_build_path)

      def __smoothie_path__(), do: @smoothie_path
      def __smoothie_use_foundation__(), do: @use_foundation
      def __smoothie_template_path__(), do: @template_dir
      def __smoothie_template_build_path__(), do: @template_build_path
      def __smoothie_layout_path__, do: @layout_file
      def __smoothie_scss_path__(), do: @scss_file
      def __smoothie_css_path__(), do: @css_file
      def __smoothie__, do: true

      # Ensure the macro is recompiled when the templates are changed
      Enum.each(@template_files, fn(file) ->
        @external_resource Path.join(@template_build_path, file)
      end)

      Enum.each(@template_files, fn(file) ->
        # read the contents of the template
        @template_contents File.read!(Path.join(@template_build_path, file))

        @template_name file
        |> String.replace(".eex", "")
        |> String.replace(".html", "_html")
        |> String.replace(".txt", "_text")
        |> String.to_atom()

        EEx.function_from_string(:def, @template_name, @template_contents, [:assigns])
      end)

      # create mock functions to avoid compilation deadlock on first `clean` compilation
      if @template_files == [] do
        Enum.filter(File.ls!(@template_dir), &(String.contains?(&1, ".html.eex")))
        |> Enum.each(fn(file) ->
          funcs = [
          file
          |> String.replace(".html.eex", "_html")
          |> String.to_atom()
          ]
          ++
          [
          file
          |> String.replace(".html.eex", "_text")
          |> String.to_atom()
          ]
          Enum.each(funcs, fn(func) ->
            def unquote(func)(_args) do
              raise("#{unquote(file)} has not yet been compiled by smoothie, run `mix smoothie.compile`.")
            end
          end)
        end)
      end
    end
  end
end
