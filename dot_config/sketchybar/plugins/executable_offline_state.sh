#!/usr/bin/env bash
#
# Offline State Machine (pure function, no I/O).
#
# Decides how the remote (devbox) section should behave across a flaky 4G link:
# absorb brief blips without flapping, then surface an explicit `unreachable`
# indicator once the devbox stays gone. It is a PURE transition
#
#     (prev_state, poll_result) -> next_state
#
# with NO network, NO disk, NO sketchybar -- exactly like the pure Context
# Resolver (slice 01) and the remote poll `--parse` parser (slice 05). The
# controller (focus.sh) owns persisting prev_state / fail_count across the ~1s
# polls; that bookkeeping is deliberately kept OUT of this function.
#
# States (the serialized `prev_state` the controller round-trips):
#   connected            last poll succeeded; the live list is current
#   stale<TAB><n>        n consecutive failures so far, still within grace;
#                        the last-known list is held on screen (no flap)
#   unreachable          failures reached the threshold; show `devbox ⚠ unreachable`
#
# An empty / unrecognized prev_state is treated as a clean start (no prior
# failures), so the very first poll of a focus session starts from zero.
#
# Usage:
#   offline_state.sh --prev "<prev_state>"   # poll_result (ok/notok blob) on stdin
#
# The poll_result on stdin is the Remote Poller's structured output verbatim:
# its first line is `ok` or `notok` (the rest -- SESSION/WINDOW lines -- is the
# poller's concern, not ours; we branch only on reachability).
#
# Output (stdout), exactly two tab-tagged lines the controller consumes:
#   STATE<TAB><next serialized state>     # persist this verbatim for the next poll
#   RENDER<TAB><directive>                # what to draw THIS tick:
#       connected    -> render the fresh window list from this poll
#       stale        -> hold: keep whatever the remote list last showed
#       unreachable  -> show the explicit `devbox ⚠ unreachable` indicator
#
# Threshold: the first FAIL_THRESHOLD consecutive failures stay in `stale`
# (grace, last-known list held); the (FAIL_THRESHOLD + 1)th failure tips into
# `unreachable`. The default below absorbs a couple of blips before surfacing
# `unreachable`, matching the PRD's "~2-3 consecutive failures" window.
FAIL_THRESHOLD="${FAIL_THRESHOLD:-2}"

prev=""
while (( $# > 0 )); do
  case "$1" in
    --prev) prev="$2"; shift 2 ;;
    *) echo "offline_state.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
done

# Reachability is the only thing we branch on: the poll result's first line is
# `ok` (reachable, list present) or anything else (`notok`/empty -> a failure).
read -r status _ || true

if [[ "$status" == "ok" ]]; then
  # Success from any prior state -> connected, failure count reset, draw live.
  printf 'STATE\t%s\n' "connected"
  printf 'RENDER\t%s\n' "connected"
  exit 0
fi

# A failure. Recover the running consecutive-failure count from prev_state.
# `connected` / empty / anything unrecognized means "no failures yet" -> 0.
#
# prev_state wire grammar (the single source of truth for the persisted format,
# round-tripped verbatim by the controller; one of):
#     connected
#     stale<TAB><n>        n = consecutive-failure count, an integer >= 1
#     unreachable
# The same grammar is emitted by the `printf 'STATE\t...'` lines below.
fail=0
case "$prev" in
  unreachable)
    # Already past the threshold: stay unreachable (no count needed -- we don't
    # climb any higher, and recovery only happens on an `ok`, handled above).
    printf 'STATE\t%s\n' "unreachable"
    printf 'RENDER\t%s\n' "unreachable"
    exit 0
    ;;
  stale*)
    # `stale<TAB><n>`: pull the prior consecutive-failure count.
    IFS=$'\t' read -r _ fail <<< "$prev"
    [[ "$fail" =~ ^[0-9]+$ ]] || fail=0
    ;;
  *)
    fail=0
    ;;
esac

fail=$(( fail + 1 ))

if (( fail > FAIL_THRESHOLD )); then
  # Grace exhausted: the devbox has stayed gone past the threshold.
  printf 'STATE\t%s\n' "unreachable"
  printf 'RENDER\t%s\n' "unreachable"
else
  # Still inside the grace window: hold the last-known list, don't flap.
  printf 'STATE\tstale\t%s\n' "$fail"
  printf 'RENDER\t%s\n' "stale"
fi
