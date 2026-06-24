#!/usr/bin/env bash
#
# Transcode lesson videos to AV1 (libsvtav1) + Opus in WebM container.
# Originals are kept; HTML can be re-pointed manually after QC.
#
# Usage:
#   ./zerocoder-transcode.sh <lesson-dir>
#
# Tunables (env):
#   CRF       — SVT-AV1 quality, lower=better. Default 38.
#   PRESET    — 0..13, lower=slower/better. Default 6.
#   AUDIO_KBPS — Opus bitrate. Default 96.
#   SAVE_ORIGINAL — keep source .mp4 after successful transcode (default false).
#                   Set true only for debugging.
#
# Defaults chosen empirically from full codec comparison sweep
# (83 variants across libx265, hevc_vaapi, rav1e, libsvtav1).
# See:
#   video-codecs-compare.sh         — encoding sweep generator
#   video-codecs-generate-report.sh — SSIM/VMAF measurement + report
#   video-codecs-render-xlsx.py     — XLSX renderer
#   downloaded.1280x720/videos/compare/compare-results.{yaml,md,xlsx}
#
# Winning variant: svtav1 crf=38 preset=6 plain
#   source : 161.46 MB, h264 1280x720, 551s
#   encoded:  13.79 MB  (ratio 0.085, ~12x compression)
#   VMAF   :  97.11     (perceptually transparent, >95 threshold)
#   SSIM   :   0.9983
#   time   :  286s on 9m source (~0.52x realtime CPU encode)
#
# Why this point on the Pareto frontier:
#   - crf32 p4 gives vmaf 97.28 but +22% size (16.85 MB) for imperceptible
#     quality gain (VMAF JND ~1 point)
#   - crf40 p6 gives -5% size (13.10 MB) at vmaf 97.05 — also viable, kept
#     crf38 for headroom on potential re-encodes
#   - x265 veryslow at comparable size scores lower vmaf (96.0-96.4)
#     and takes 8-9x longer (~2400s)
#   - hevc_vaapi is 4x faster (~70s) but caps at vmaf ~96.6 with bigger files
set -euo pipefail

DIR="${1:?Usage: $0 <lesson-dir>}"
CRF="${CRF:-38}"
PRESET="${PRESET:-6}"
AUDIO_KBPS="${AUDIO_KBPS:-96}"
SAVE_ORIGINAL="${SAVE_ORIGINAL:-false}"

VDIR="${DIR%/}/videos"
[[ -d "${VDIR}" ]] || { echo "ERROR: ${VDIR} not found" >&2; exit 1; }

command -v ffmpeg >/dev/null || { echo "ERROR: ffmpeg not found" >&2; exit 1; }

shopt -s nullglob
mapfile -t MP4S < <(find "${VDIR}" -maxdepth 1 -type f -name '*.mp4' | sort)
[[ ${#MP4S[@]} -gt 0 ]] || { echo "No .mp4 files in ${VDIR}"; exit 0; }

echo "==> Transcoding ${#MP4S[@]} file(s) | CRF=${CRF} preset=${PRESET} audio=${AUDIO_KBPS}k"

for SRC in "${MP4S[@]}"; do
    BASE="$(basename "${SRC}" .mp4)"
    DST="${VDIR}/${BASE}.av1.webm"
    if [[ -s "${DST}" ]]; then
        echo "  -> skip (exists): ${DST}"
        continue
    fi
    SIZE_IN="$(du -h "${SRC}" | cut -f1)"
    echo "  -> ${BASE}.mp4 (${SIZE_IN}) → ${BASE}.av1.webm"
    ffmpeg -hide_banner -loglevel error -stats \
        -i "${SRC}" \
        -c:v libsvtav1 -crf "${CRF}" -preset "${PRESET}" \
        -pix_fmt yuv420p10le \
        -g 240 \
        -c:a libopus -b:a "${AUDIO_KBPS}k" \
        -y "${DST}" \
        || { echo "  ERROR: ffmpeg failed on ${SRC}"; rm -f "${DST}"; continue; }
    SIZE_OUT="$(du -h "${DST}" | cut -f1)"
    echo "     done: ${SIZE_OUT}"
done

echo ""
echo "==> Sizes:"
printf "  %-50s %10s %10s\n" "FILE" "MP4" "AV1.WEBM"
for SRC in "${MP4S[@]}"; do
    BASE="$(basename "${SRC}" .mp4)"
    DST="${VDIR}/${BASE}.av1.webm"
    [[ -f "${DST}" ]] || continue
    printf "  %-50s %10s %10s\n" "${BASE}" \
        "$(du -h "${SRC}" | cut -f1)" \
        "$(du -h "${DST}" | cut -f1)"
done

if [[ "${SAVE_ORIGINAL}" != "true" ]]; then
    echo ""
    echo "==> Removing originals (SAVE_ORIGINAL=false)"
    for SRC in "${MP4S[@]}"; do
        BASE="$(basename "${SRC}" .mp4)"
        DST="${VDIR}/${BASE}.av1.webm"
        if [[ -s "${DST}" ]]; then
            rm -f "${SRC}"
            echo "  removed: ${SRC}"
        else
            echo "  kept (no webm): ${SRC}"
        fi
    done
fi

echo ""
if [[ "${SAVE_ORIGINAL}" == "true" ]]; then
    echo "==> Done. Originals kept (SAVE_ORIGINAL=true)."
else
    echo "==> Done. Originals removed."
fi
