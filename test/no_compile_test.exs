defmodule NoCompileTest do
  use ExUnit.Case

  def clean_build_dir() do
    no_compile = Path.expand("test/data/no_compile/templates/build")
    File.exists?(no_compile) && File.rm_rf!(no_compile)
  end

  setup_all do
    clean_build_dir()
    :ok
  end
  test "raises an error when the mix smoothie.compile task has not yet been run for NoCompile.Mailer" do
    assert_raise(RuntimeError, fn() ->
      try do
        NoCompile.Mailer.html()
      rescue
        e in RuntimeError ->
          assert e.message == "welcome.html.eex has not yet been compiled by smoothie, run `mix smoothie.compile`."
          raise(RuntimeError, message: e.message)
      end
    end)
  end

end