# Changelog

## v3.1.0

- Option to set the `:template_build_dir` in `config smoothie: ...`
- Anticipate new directory structure for pre phoenix 1.3 and post phoenix 1.3
- Update dependencies for documentation generation
- Slight change to the way the path is generated, same outcome but allows for where
the user enters `../../path` - before this would not expand to the correct path. With
changes, it should do so.
- Added test for expected empty mock function on compilation failure
- Added test for where the `:template_build_dir` is being used.
- Minor changes to syntax and readme.
- Requires upgrading to new companion of elixir-smoothie, `> 2.0.5`.
