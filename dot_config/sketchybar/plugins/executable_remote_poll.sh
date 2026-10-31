#!/usr/bin/env bash
#
# Remote Poller (I/O shell + a separate pure parser).
#
# Interface:   remote_poll.sh   (no arguments)
#   Connects to the devbox over the warm, multiplexed OpenSSH `devbox-bar` alias
#   (slice 02), selects the session of the single attached client there, lists
#   that session's windows, and prints a structured result on stdout:
#
#   The poll target is deliberately the FIXED `devbox-bar` alias, not a caller-
#   supplied host. `devbox-bar` is slice 02's single source of truth for the
#   connection: it carries ControlMaster multiplexing, keyless tailnet auth,
#   ConnectTimeout, and BatchMode. The context's host label (devbox:<host>)
#   resolves to the devbox's real hostname, which is NOT a valid ssh target and
#   would bypass the entire slice-02 transport -- so this poller takes no host
#   argument and there is, today, exactly one devbox.
#
#     ok
#     SESSION<TAB><session-name><TAB><session-index>
#     WINDOW<TAB><active><TAB><index><TAB><name>
#     WINDOW<TAB>...
#
#   The WINDOW lines' active/index/name fields mirror
#   `tmux list-windows -F '#{window_active}\t#{window_index}\t#{window_name}'`,
#   so the caller can feed them straight to the shared window-list renderer
#   (slice 04). The SESSION index is the 1-based position of the session in
#   `list-sessions` order, matching the local session item's convention.
#
#   A failed / timed-out / empty connection (no tmux server on the devbox, or no
#   attached client) prints exactly:
#
#     notok
#
#   and exits 0. Offline/grace handling is slice 06 -- here {ok:false} is the
#   whole failure story; this slice is the reachable happy path.
#
# The raw-output PARSER is a separate PURE function (raw remote text -> the
# structured ok/SESSION/WINDOW lines above), with no I/O, mirroring the pure
# Context Resolver from slice 01. It is exposed via:
#
#     remote_poll.sh --parse   # raw remote blob on stdin -> structured on stdout
#
# so it can be exercised in isolation. The network shell (default mode) does the
# one SSH round-trip, then pipes the raw blob through --parse.

# ---------------------------------------------------------------------------
# Remote command: emitted to the devbox over SSH. Pure tmux/awk on the far end;
# it produces the RAW blob the parser consumes. Kept as a single string so the
# poll is exactly one round-trip over the warm master.
#
# Raw blob grammar (one of):
#   - empty output            -> no tmux server / unreachable
#   - "NOCLIENT\n"            -> tmux up but no attached client to mirror
#   - "S\t<name>\t<index>\n"  followed by zero or more
#     "W\t<active>\t<index>\t<name>\n"   lines for that session
#
# The session mirrored is the one the single attached client is viewing
# (list-clients' client_session); its index is its 1-based position in
# list-sessions order. If tmux is not running, `tmux list-clients` fails and the
# `||` arm prints nothing, yielding the empty-output (unreachable) blob.
# ---------------------------------------------------------------------------
read -r -d '' REMOTE_CMD <<'EOF'
sess=$(tmux list-clients -F '#{client_session}' 2>/dev/null | head -n1)
if [ -z "$sess" ]; then
  echo NOCLIENT
  exit 0
fi
idx=$(tmux list-sessions -F '#{session_name}' 2>/dev/null \
  | awk -v s="$sess" '$0==s{print NR; exit}')
printf 'S\t%s\t%s\n' "$sess" "$idx"
tmux list-windows -t "$sess" \
  -F '#{window_active}	#{window_index}	#{window_name}' 2>/dev/null \
  | awk -F'\t' '{
      # active and index are tab-free; the name is the trailing field. If the
      # window name itself contains a tab, keep ALL of it (fields 3..NF) so the
      # name is not truncated downstream -- the name stays the last field.
      name = $3
      for (i = 4; i <= NF; i++) name = name "\t" $i
      printf "W\t%s\t%s\t%s\n", $1, $2, name
    }'
EOF

# ---------------------------------------------------------------------------
# parse_raw: PURE parser. Raw remote blob on stdin -> structured result on
# stdout. No I/O, no network -- it only transforms text, so it mirrors the pure
# Context Resolver and can be tested in isolation.
#
#   empty / NOCLIENT / no SESSION line / no windows -> "notok"
#   otherwise -> "ok", a SESSION line, and the WINDOW lines.
# ---------------------------------------------------------------------------
parse_raw() {
  awk -F'\t' '
    /^NOCLIENT$/ { next }
    $1 == "S" { have_session = 1; sname = $2; sidx = $3; next }
    $1 == "W" {
      # Re-assemble active\tindex\tname, keeping the name (fields 4..NF) whole
      # even if it contains a tab, so the trailing name field for the renderer is
      # not truncated. active ($2) and index ($3) are tab-free.
      name = $4
      for (i = 5; i <= NF; i++) name = name "\t" $i
      nwin++; win[nwin] = $2 "\t" $3 "\t" name
      next
    }
    END {
      # A reachable, mirror-able devbox needs an attached session AND at least
      # one window; anything short of that is {ok:false} for this slice.
      if (!have_session || nwin == 0) { print "notok"; exit 0 }
      print "ok"
      print "SESSION\t" sname "\t" sidx
      for (i = 1; i <= nwin; i++) print "WINDOW\t" win[i]
    }
  '
}

if [[ "$1" == "--parse" ]]; then
  parse_raw
  exit 0
fi

# Default (network) mode takes no arguments: the poll target is the fixed
# `devbox-bar` alias (see the interface note above), not a caller-supplied host.
# Reject a stray argument rather than silently ignoring it -- a caller passing a
# host is working from a wrong mental model and should hear about it.
if [[ -n "$1" ]]; then
  echo "remote_poll.sh: usage: remote_poll.sh | --parse  (polls the fixed devbox-bar alias; takes no host)" >&2
  exit 2
fi

# One SSH round-trip over the warm `devbox-bar` master. BatchMode/ConnectTimeout
# live in the ssh config (slice 02), so a blip or offline node fails fast with
# empty output rather than hanging the bar. Stderr is dropped: a failed connect
# must look the same as an empty tmux (both -> notok), never leak SSH chatter
# into the parsed blob.
raw=$(ssh devbox-bar "$REMOTE_CMD" 2>/dev/null)

# Funnel the raw blob through the pure parser. A non-zero ssh exit (timeout,
# offline) leaves $raw empty, which the parser maps to "notok".
printf '%s' "$raw" | parse_raw
