# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/), for one Apple Silicon Mac.

## New Mac

```sh
xcode-select --install
```

Wait for that to finish, then:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <github-user>
```

Then work through [CHECKLIST.md](CHECKLIST.md).

## Day to day

| Task | Command |
|---|---|
| Edit a managed file | `chezmoi edit <file>`, or edit it and run `chezmoi re-add` |
| Preview changes | `chezmoi diff` |
| Apply changes | `chezmoi apply` |
| Update the Brewfile | `brew bundle dump --file="$(chezmoi source-path)/Brewfile" --force` |
