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

The package is intended to be installable from MELPA once the repository is
published and a MELPA recipe is merged.

Until then, place `exec-path-from-powershell.el` on your `load-path` and add:

```elisp
(require 'exec-path-from-powershell)
```

## Development

Run the MELPA-oriented package checks locally with:

```sh
emacs -Q --batch -l scripts/quality-check.el exec-path-from-powershell.el
```

That batch entrypoint installs and runs the tools MELPA recommends for package
quality work, including `checkdoc`, `package-lint`, and `flycheck-package`.

To validate the package through a local MELPA checkout without depending on
badge generation, use:

```sh
make USER_CONFIG='"(setq package-build-badge-data nil)"' recipes/exec-path-from-powershell
make sandbox INSTALL=exec-path-from-powershell
MELPA_CHANNEL=stable make USER_CONFIG='"(setq package-build-badge-data nil)"' recipes/exec-path-from-powershell
MELPA_CHANNEL=stable make sandbox INSTALL=exec-path-from-powershell
```
