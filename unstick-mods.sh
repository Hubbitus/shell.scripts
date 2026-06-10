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

# X11 keysym names per modifier (left+right). Used with xdotool --clearmodifiers,
# which forces a full keysym up sequence — confirmed to clear stuck Ctrl in KWin
# 6.6.5 Wayland when plain `xdotool keyup ctrl` did not.
declare -A XSYMS=(
    [ctrl]="Control_L Control_R"
    [alt]="Alt_L Alt_R Meta_L"
    [shift]="Shift_L Shift_R"
    [super]="Super_L Super_R"
)

log() { logger -t unstick-mods "$*"; echo "unstick-mods: $*" >&2; }

# ydotoold on Fedora runs with --socket-path=/tmp/.ydotool_socket, but the
# client defaults to /run/user/$UID/.ydotool_socket. Autodetect actual socket.
if [[ -z "${YDOTOOL_SOCKET:-}" ]]; then
    for s in "/run/user/$(id -u)/.ydotool_socket" "/tmp/.ydotool_socket" "/run/ydotool.sock"; do
        if [[ -S "$s" ]]; then export YDOTOOL_SOCKET="$s"; break; fi
    done
fi

released=()
failed=()

for m in "${MODS[@]}"; do
    ok=0

    # 1. xdotool with --clearmodifiers + explicit keysyms. Confirmed to work
    #    where plain `xdotool keyup ctrl` did NOT (Plasma 6.6.5 Wayland).
    if command -v xdotool >/dev/null 2>&1 && [[ -n "${XSYMS[$m]:-}" ]]; then
        if xdotool keyup --clearmodifiers ${XSYMS[$m]} 2>/dev/null; then ok=1; fi
    fi

    # 2. ydotool fallback (native Wayland uinput) — useful when focus is in
    #    a pure-Wayland window and Xwayland-only release didn't propagate.
    if command -v ydotool >/dev/null 2>&1 && [[ -n "${YCODES[$m]:-}" ]]; then
        for code in ${YCODES[$m]}; do
            ydotool key "${code}:0" >/dev/null 2>&1 && ok=1
        done
    fi

    if (( ok )); then released+=("$m"); else failed+=("$m"); fi
done

log "released: ${released[*]:-none}; failed: ${failed[*]:-none}"

# Desktop notification so the user sees feedback when invoked via a global
# hotkey. Falls back silently if notify-send is missing.
if command -v notify-send >/dev/null 2>&1; then
    # NOTE: KDE 6 NotificationManager hides toasts from unknown app-ids by
    # default — do NOT pass `-a unstick-mods` here, it silences the popup.
    if (( ${#failed[@]} == 0 )); then
        notify-send -i input-keyboard -t 2000 \
            "Modifiers released" "${released[*]}"
    else
        notify-send -i dialog-warning -u critical -t 4000 \
            "unstick-mods: partial" \
            "released: ${released[*]:-none}; failed: ${failed[*]}"
    fi
fi

(( ${#failed[@]} == 0 ))
