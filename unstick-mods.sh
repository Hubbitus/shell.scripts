#!/usr/bin/env bash
# unstick-mods.sh — release stuck modifier keys (Ctrl/Alt/Shift/Super) in KDE Wayland.
#
# Usage:
#   unstick-mods.sh                 # release all modifiers
#   unstick-mods.sh ctrl alt        # release only listed
#   unstick-mods.sh --portal        # skip key replay, kill xdg-desktop-portal-kde
#   unstick-mods.sh --no-portal-ask # never prompt for portal restart
#
# Strategy:
#   1. xdotool keyup --clearmodifiers <keysyms>  (works for Xwayland clients)
#   2. ydotool key NN:0                          (native Wayland uinput fallback)
#   3. If both above don't actually clear the latch (common cause:
#      xdg-desktop-portal-kde InputCapture leak after a Deny / app crash),
#      ask the user whether to restart portal-kde and do it on confirmation.

set -u

log() { logger -t unstick-mods "$*"; echo "unstick-mods: $*" >&2; }

MODS_ALL=(ctrl alt shift super)

portal_mode=ask     # ask | yes | no
portal_only=0
args=()
for a in "$@"; do
    case "$a" in
        --portal)         portal_only=1 ;;
        --no-portal-ask)  portal_mode=no ;;
        --portal-yes)     portal_mode=yes ;;
        *)                args+=("$a") ;;
    esac
done
MODS=("${args[@]:-${MODS_ALL[@]}}")

restart_portal_kde() {
    local pid
    pid=$(pgrep -f '(^|/)xdg-desktop-portal-kde($|\s)' | head -1)
    if [[ -z "$pid" ]]; then
        log "portal-kde not running — nothing to restart"
        return 1
    fi
    log "killing xdg-desktop-portal-kde (pid=$pid); DBus will reactivate it"
    kill "$pid" 2>/dev/null || return 1
    # Wait briefly for DBus to respawn it.
    for _ in 1 2 3 4 5; do
        sleep 0.5
        local newpid
        newpid=$(pgrep -f '(^|/)xdg-desktop-portal-kde($|\s)' | head -1)
        if [[ -n "$newpid" && "$newpid" != "$pid" ]]; then
            log "portal-kde respawned (pid=$newpid)"
            return 0
        fi
    done
    log "portal-kde did not respawn within 2.5s"
    return 1
}

ask_portal_restart() {
    # Returns 0 if user confirms restart.
    local msg="Modifiers still stuck after xdotool/ydotool.
This is usually caused by xdg-desktop-portal-kde leaking an InputCapture grab
(e.g. after denying a portal prompt or after Omnissa Horizon / VDI crash).

Restart xdg-desktop-portal-kde now?"
    if command -v kdialog >/dev/null 2>&1; then
        kdialog --title "unstick-mods" --yesno "$msg"
        return $?
    fi
    if command -v zenity >/dev/null 2>&1; then
        zenity --question --title="unstick-mods" --text="$msg"
        return $?
    fi
    # No GUI prompt available — fall back to TTY if interactive.
    if [[ -t 0 ]]; then
        read -rp "Restart xdg-desktop-portal-kde? [y/N] " ans
        [[ "$ans" =~ ^[Yy] ]]
        return $?
    fi
    return 1
}

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

# ydotoold on Fedora runs with --socket-path=/tmp/.ydotool_socket, but the
# client defaults to /run/user/$UID/.ydotool_socket. Autodetect actual socket.
if [[ -z "${YDOTOOL_SOCKET:-}" ]]; then
    for s in "/run/user/$(id -u)/.ydotool_socket" "/tmp/.ydotool_socket" "/run/ydotool.sock"; do
        if [[ -S "$s" ]]; then export YDOTOOL_SOCKET="$s"; break; fi
    done
fi

# --portal: skip replay, just restart portal-kde and exit.
if (( portal_only )); then
    if restart_portal_kde; then
        command -v notify-send >/dev/null 2>&1 && notify-send -i input-keyboard -t 2000 \
            "Modifiers released" "xdg-desktop-portal-kde restarted"
        exit 0
    else
        command -v notify-send >/dev/null 2>&1 && notify-send -i dialog-warning -u critical -t 4000 \
            "unstick-mods" "portal-kde restart failed"
        exit 1
    fi
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

# Replay finished. Even when xdotool/ydotool report success the latch may
# still be held by xdg-desktop-portal-kde (common after Omnissa Horizon /
# VDI crashes or after denying an InputCapture portal prompt). Offer to
# restart portal-kde as a last resort, unless suppressed.
case "$portal_mode" in
    no)   : ;;
    yes)  restart_portal_kde ;;
    ask)
        if ask_portal_restart; then restart_portal_kde; fi
        ;;
esac

(( ${#failed[@]} == 0 ))
