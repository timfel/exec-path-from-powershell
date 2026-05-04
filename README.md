# exec-path-from-powershell

`exec-path-from-powershell` provides a PowerShell-backed variant of the
`exec-path-from-shell` API for Emacs on Windows.

If `exec-path-from-shell-shell-name` is set to `powershell.exe` or `pwsh.exe`,
the package advises `exec-path-from-shell-getenvs` and
`exec-path-from-shell-printf` to fetch environment values through PowerShell
instead of a POSIX shell.

It can also merge the Visual Studio developer environment into the imported
variables when desired.

## Installation

Once the MELPA recipe is merged, install the package alongside
`exec-path-from-shell` and enable it explicitly:

```elisp
(require 'exec-path-from-shell)
(require 'exec-path-from-powershell)

(setq exec-path-from-shell-shell-name "pwsh.exe")
(exec-path-from-powershell-enable)
```

## Development

This repository is set up to be developed next to a sibling MELPA checkout:

```text
~/dev/epfps/
  exec-path-from-powershell/
  melpa/
```

Run the package lint, documentation, byte-compilation, and ERT checks with:

```sh
make check
```

That target bootstraps local dependencies into `.cache/elpa` and runs
`checkdoc`, `package-lint`, `flycheck-package`, byte-compilation, and the ERT
suite in an isolated `HOME`.

To validate the package through the sibling MELPA checkout, use:

```sh
make melpa-check
make melpa-sandbox
```

Stable validation is also wired up for tagged releases:

```sh
make melpa-stable-check
make melpa-stable-sandbox
```

## MELPA Readiness Checklist

- [x] Main library header includes lexical binding, package metadata, and GPL boilerplate.
- [x] Public activation entry points are autoloadable via `exec-path-from-powershell-enable` and `exec-path-from-powershell-disable`.
- [x] Repository includes `README.md`, `LICENSE`, a canonical MELPA recipe, and batch scripts for local checks.
- [x] Local `make check` covers `checkdoc`, `package-lint`, `flycheck-package`, byte-compilation, and ERT.
- [x] GitHub Actions runs the local check suite across multiple Emacs versions and validates the MELPA recipe.
- [x] Stable builds are expected to come from Git tags such as `v1.0`, `v1.1`, and so on.
