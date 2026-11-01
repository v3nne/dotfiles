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

- [ ] Connect the Mac to the same Tailscale account with `sudo brew services start tailscale` and `tailscale up`
- [ ] Check that your tailnet's access rules allow Tailscale SSH
- [ ] Disable key expiry for the server in the Tailscale admin console, because an expired key leaves only your provider's web console as a way in
- [ ] Add the `Host devbox` entry that `bootstrap.sh` prints to `~/.ssh/config` on the Mac
- [ ] Log in as `venne`, run `claude` and log in, using the link on your Mac and pasting a code back if asked
- [ ] To push from the server, create a key with `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""`, add it to GitHub, and run `chezmoi git -- remote set-url origin git@github.com:v3nne/dotfiles.git`

### Check it

- [ ] A second `chezmoi apply` does nothing, and `chezmoi status` is empty
- [ ] `nvim --version` shows 0.12.x, and `tmux -V` shows 3.8
- [ ] `lazygit`, `lazydocker`, `tldr` and `bw` all start
- [ ] `docker run hello-world` works without `sudo`, and `docker compose version` works
- [ ] `devbox` on the Mac reconnects to the same tmux session after you disconnect
- [ ] No "unknown terminal" errors, the tmux theme stays dark, and the Alt shortcuts work
- [ ] Neovim plugins install, and `blink.cmp` works
- [ ] Mason installs `pyright`, `ts_ls`, `gopls` and `lua_ls`
- [ ] Tree-sitter parsers build, and `peek.nvim` causes no errors on startup
- [ ] Copying from Neovim and from tmux copy mode reaches your Mac's clipboard
- [ ] `git push` to this repo works with the server's key
- [ ] `btop` opens with the Kanagawa theme
- [ ] Add a small shared tool to the `Brewfile` on one machine, push, and run `dotu` on the other. It should install there. Then remove it using the routine in the README

### Server admin

`bootstrap.sh` closes public access, leaving SSH over Tailscale only, and turns on automatic security updates.

- [ ] Check that `ssh venne@<the server's public IP>` from the Mac now fails, while `ssh devbox` works
- [ ] Check that you can log in through your provider's web console, which is the way back in if Tailscale fails
- [ ] Publish Docker ports to the tailnet with `-p <the server's Tailscale IP>:8080:80`, because a plain `-p 8080:80` is now only reachable from the server itself
- [ ] Reboot now and then to pick up kernel updates, and run `brew upgrade` and `dnf upgrade` regularly, since security updates only cover some `dnf` packages
