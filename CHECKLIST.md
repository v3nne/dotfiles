# Manual steps

## New Mac

- [ ] Log in to Bitwarden and restore SSH keys and `~/.ssh/config` (`chmod 600` the keys)
- [ ] Install the Karabiner-DriverKit-VirtualHIDDevice driver and approve it in System Settings
- [ ] Allow kanata under Privacy & Security > Input Monitoring
- [ ] Arrange the Finder sidebar and tags
- [ ] Log out and back in so trackpad and keyboard settings take effect
- [ ] Log in to apps

## New Fedora server

Work and AWS keys and `~/.ssh/config` stay off the server.

### Finish the install

- [ ] Check that your Mac is on the same Tailscale account, and that your tailnet's access rules allow Tailscale SSH
- [ ] Add the `Host devbox` entry that `bootstrap.sh` prints to `~/.ssh/config` on the Mac
- [ ] Log in as `venne`, run `claude` and log in, using the link on your Mac and pasting a code back if asked
- [ ] To push from the server, create a key with `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""`, add it to GitHub, and run `chezmoi git -- remote set-url origin git@github.com:v3nne/dotfiles.git`

### Check it

- [ ] A second `chezmoi apply` does nothing, and `chezmoi status` is empty
- [ ] `nvim --version` shows 0.12.x, and `tmux -V` shows 3.8
- [ ] `lazygit`, `lazydocker`, `tldr` and `bw` all start
- [ ] `docker run hello-world` works without `sudo`, and `docker compose version` works
- [ ] `dev` on the Mac reconnects to the same tmux session after you disconnect
- [ ] No "unknown terminal" errors, the tmux theme stays dark, and the Alt shortcuts work
- [ ] Neovim plugins install, and `blink.cmp` works
- [ ] Mason installs `pyright`, `ts_ls`, `gopls` and `lua_ls`
- [ ] Tree-sitter parsers build, and `peek.nvim` causes no errors on startup
- [ ] Copying from Neovim and from tmux copy mode reaches your Mac's clipboard
- [ ] `git push` to this repo works with the server's key
- [ ] `btop` opens with the Kanagawa theme
- [ ] Add a small shared tool to the `Brewfile` on one machine, push, and run `dotu` on the other. It should install there. Then remove it using the routine in the README

### Server admin

- [ ] Once Tailscale SSH is confirmed, decide whether normal SSH should be limited to Tailscale. Keep a console or other way in before locking anything down
- [ ] Set the firewall, remembering that ports published by Docker can bypass it
- [ ] Turn on automatic security updates
- [ ] Run `brew upgrade` and `dnf upgrade` regularly, since neither runs on its own
