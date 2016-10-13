defmodule Smoothie do
  require EEx

  Module.register_attribute(__MODULE__, :modules, accumulate: true)
  def register_module(module) do
    @modules module
  end

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      require Logger

      Smoothie.register_module(__MODULE__)

      @smoothie_path __ENV__.file
      |> Path.expand()
      |> Path.dirname()

      @use_foundation Keyword.get(opts, :use_foundation)
      @template_dir Keyword.get(opts, :template_dir)
      @layout_file Keyword.get(opts, :layout_file)
      @scss_file Keyword.get(opts, :scss_file)
      @css_file Keyword.get(opts, :css_file)

      def __smoothie_scss_path__, do: @scss_file && Path.join([@smoothie_path, @scss_file])
      def __smoothie_css_path__, do: @css_file && Path.join([@smoothie_path, @css_file])
      def __smoothie_path__, do: @smoothie_path
      def __smoothie_use_foundation__, do: @use_foundation

      @template_path Path.join(@smoothie_path, @template_dir)
      def __smoothie_template_path__, do: @template_path

      unless File.exists?(@template_path), do: raise("Smoothie: Template path not found: '#{@template_path}'")
      @template_build_path Path.join(@template_path, "build")
      unless File.exists?(@template_build_path), do: File.mkdir!(@template_build_path)

      @layout_path if @layout_file, do: Path.join(@smoothie_path, @layout_file)
      def __smoothie_layout_path__, do: @layout_path
      unless @layout_path == nil || File.exists?(@layout_path), do: raise("Smoothie: Layout file not found: '#{@layout_path}'")

      @template_files File.ls!(@template_build_path)

      def __smoothie__ do
        %{
          __smoothie_template_path__: __smoothie_template_path__(),
          __smoothie_layout_path__: __smoothie_layout_path__(),
          __smoothie_use_foundation__: __smoothie_use_foundation__(),
          __smoothie_scss_path__: __smoothie_scss_path__(),
          __smoothie_css_path__: __smoothie_css_path__(),
        }
      end

      # Ensure the macro is recompiled when the templates are changed
      Enum.each(@template_files, fn(file) ->
        @external_resource Path.join(@template_build_path, file)
      end)

      Enum.each(@template_files, fn(file) ->
        # read the contents of the template
        @template_contents File.read!(Path.join(@template_build_path, file))

        # capture variables that are defined in the template
        @variables Regex.scan(~r/<%=(.*?)%>/, @template_contents)
        |> Enum.map(fn(match) ->
          match
          |> Enum.at(1)
          |> String.trim(" ")
          |> String.to_atom()
        end)
        |> Enum.uniq

        # create assignment macro code for in the function block
        @variable_assignments Enum.map(@variables, fn(name) ->
          quote do
            unquote(Macro.var(name, nil)) = args[unquote(name)]
          end
        end)

        # generate function name from file name
        @template_name file
        |> String.replace(".eex", "")
        |> String.replace(".html", "_html")
        |> String.replace(".txt", "_text")
        |> String.to_atom

        @compiled EEx.compile_string(@template_contents, [])

        def unquote(@template_name)(args) do
          unquote(@variable_assignments)
          unquote(@compiled)
        end
      end)
    end
  end
end
