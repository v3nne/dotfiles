# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/), for one Apple Silicon Mac and one terminal-only x86 Fedora server.

## New Mac

```sh
xcode-select --install
```

Wait for that to finish, then:

```sh
cd ~
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply v3nne
```

Run it from your home folder, because the installer's `.local/bin` path is relative to where you run it.

Then work through the Mac list in [CHECKLIST.md](CHECKLIST.md).

## New Fedora server

On a fresh server, as root:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/v3nne/dotfiles/main/bootstrap.sh)"
```

This creates the `venne` user, installs everything as that user, then closes the server to everything except Tailscale. It stops twice: once at the start to choose a password for `venne`, and once at the end for a Tailscale link to open on your Mac. If it fails partway, start again on a new server.

Then work through the Fedora list in [CHECKLIST.md](CHECKLIST.md).

## Day to day

| Task | Command |
|---|---|
| Edit a managed file | `chezmoi edit <file>`, or edit it and run `chezmoi re-add` |
| Edit `.zprofile`, `.zshrc` or `tmux.conf` | `dote <file>`, because `chezmoi re-add` skips templates |
| Preview changes | `chezmoi diff` |
| Apply changes | `chezmoi apply` |
| Pull and apply changes from the other machine | `dotu` |
| Connect to the server from the Mac | `devbox`, in a Ghostty window outside tmux |
| Update chezmoi | `chezmoi upgrade` |

## Packages

Both machines share one `Brewfile`. Don't run `brew bundle dump --force`, because it would wipe out the Mac-only block.

- **Shared tools:** run `brew bundle add <name> --file="$(chezmoi source-path)/Brewfile"`, or edit the file by hand. Check that the new line lands outside the `if OS.mac?` block.
- **Mac-only tools:** edit the file by hand, inside the block.
- **Removals:** delete the line, run `brew bundle cleanup --file="$(chezmoi source-path)/Brewfile"` to see the extras, then uninstall them by hand on each machine.

Fedora system packages, Docker and Tailscale are installed with `dnf` by the scripts in `.chezmoiscripts`.
