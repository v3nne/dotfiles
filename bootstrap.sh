#!/bin/bash
# Sets up a new Fedora server. Run it as root, see the README.
set -euo pipefail

user=venne
branch="${DEVBOX_BRANCH:-main}"
sudoers=/etc/sudoers.d/90-devbox-bootstrap

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this as root." >&2
  exit 1
fi

dnf install -y sudo git curl

useradd -m -G wheel "$user"
echo "Choose a password for $user, which sudo will ask for from now on."
until passwd "$user"; do :; done

# Root's SSH key keeps working for the new user
if [ -f /root/.ssh/authorized_keys ]; then
  install -d -m 700 -o "$user" -g "$user" "/home/$user/.ssh"
  install -m 600 -o "$user" -g "$user" /root/.ssh/authorized_keys "/home/$user/.ssh/authorized_keys"
  if command -v restorecon >/dev/null; then
    restorecon -R "/home/$user/.ssh"
  fi
fi

# Homebrew won't install as root, and the scripts can't stop for a password
trap 'rm -f "$sudoers"' EXIT
echo "$user ALL=(ALL) NOPASSWD: ALL" >"$sudoers"
chmod 440 "$sudoers"

# The new user has no terminfo for Ghostty yet, which stops tmux from starting
export TERM=xterm-256color
runuser -l "$user" -c "sh -c \"\$(curl -fsLS get.chezmoi.io/lb)\" -- init --branch $branch --apply v3nne"

# Prints a link to open on the Mac, and waits until it's approved
tailscale up --ssh

# Everything below locks the server down, so it only runs once Tailscale is up.
# Close every public service, which leaves this SSH session connected
dnf install -y firewalld dnf5-plugin-automatic
systemctl enable --now firewalld
zone="$(firewall-cmd --get-default-zone)"
for service in $(firewall-cmd --zone="$zone" --list-services); do
  if [ "$service" != dhcpv6-client ]; then
    firewall-cmd --permanent --zone="$zone" --remove-service="$service"
  fi
done
# Lets Tailscale connect directly instead of through its relays
firewall-cmd --permanent --zone="$zone" --add-port=41641/udp
firewall-cmd --permanent --zone=trusted --add-interface=tailscale0
firewall-cmd --reload

# 00 because sshd uses the first value it reads, and the image can add its own
cat >/etc/ssh/sshd_config.d/00-lockdown.conf <<EOF
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF
sshd -t
systemctl reload sshd

# Published ports skip the firewall, so make them local unless given an address
echo '{ "ip": "127.0.0.1" }' >/etc/docker/daemon.json
systemctl restart docker

mkdir -p /etc/dnf/dnf5-plugins
cat >/etc/dnf/dnf5-plugins/automatic.conf <<EOF
[commands]
upgrade_type = security
apply_updates = yes
EOF
systemctl enable --now dnf5-automatic.timer

cat <<EOF

Done. Public SSH is now closed, so keep this session open until ssh devbox works.
If you get locked out, use your provider's web console.

Add this to ~/.ssh/config on the Mac:

Host devbox
    HostName $(tailscale ip -4)
    User $user

Then run dev on the Mac, and claude on the server to log in.
EOF
