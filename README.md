# exec-path-from-powershell

`exec-path-from-powershell` makes `exec-path-from-shell` work with
`pwsh.exe` and `powershell.exe` on Windows.

When the library is loaded and `exec-path-from-shell-shell-name` points at
PowerShell, calls to `exec-path-from-shell-getenvs` and
`exec-path-from-shell-printf` are handled through PowerShell instead of a
POSIX shell.

It can also merge the Visual Studio developer environment into the imported
variables.

## Installation

Install `exec-path-from-powershell` and `exec-path-from-shell`, then point
`exec-path-from-shell` at PowerShell:

```elisp
(require 'exec-path-from-powershell)

(setq exec-path-from-shell-shell-name "pwsh.exe")
```

With `use-package`:

```elisp
(use-package exec-path-from-powershell
  :custom
  (exec-path-from-shell-shell-name "pwsh.exe"))
```

Then use `exec-path-from-shell` as usual, for example:

```elisp
(exec-path-from-shell-initialize)
```

## Visual Studio Environment

If `exec-path-from-powershell-includes-visual-studio-environment` is non-nil,
the package also imports variables from the latest supported Visual Studio
developer shell.

Relevant options:

- `exec-path-from-powershell-includes-visual-studio-environment`
- `exec-path-from-powershell-load-profile`
- `exec-path-from-powershell-visual-studio-arch`
- `exec-path-from-powershell-visual-studio-host-arch`
