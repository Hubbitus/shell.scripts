#!/usr/bin/env bash
# unstick-mods.sh — release stuck modifier keys (Ctrl/Alt/Shift/Super) in KDE Wayland.
#
# Usage:
#   unstick-mods.sh              # release all modifiers
#   unstick-mods.sh ctrl alt     # release only listed
#
# Tries xdotool first (works for Xwayland clients). Falls back to ydotool
# (native Wayland via uinput) if available.

set -u

MODS_ALL=(ctrl alt shift super)
MODS=("${@:-${MODS_ALL[@]}}")

# Linux input-event-codes for ydotool fallback (left+right variants).
declare -A YCODES=(
    [ctrl]="29 97"     # KEY_LEFTCTRL  KEY_RIGHTCTRL
    [alt]="56 100"     # KEY_LEFTALT   KEY_RIGHTALT
    [shift]="42 54"    # KEY_LEFTSHIFT KEY_RIGHTSHIFT
    [super]="125 126"  # KEY_LEFTMETA  KEY_RIGHTMETA
)

log() { logger -t unstick-mods "$*"; echo "unstick-mods: $*" >&2; }

released=()
failed=()

for m in "${MODS[@]}"; do
    ok=0

    if command -v xdotool >/dev/null 2>&1; then
        if xdotool keyup "$m" 2>/dev/null; then ok=1; fi
    fi

    if command -v ydotool >/dev/null 2>&1 && [[ -n "${YCODES[$m]:-}" ]]; then
        for code in ${YCODES[$m]}; do
            ydotool key "${code}:0" >/dev/null 2>&1 && ok=1
        done
    fi

    if (( ok )); then released+=("$m"); else failed+=("$m"); fi
done

log "released: ${released[*]:-none}; failed: ${failed[*]:-none}"
(( ${#failed[@]} == 0 ))
