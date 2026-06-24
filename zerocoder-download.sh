#!/usr/bin/env bash
#
# Download a zerocoder.ru (GetCourse platform) lesson page for offline viewing,
# including GCVH videos (HLS → MP4 via ffmpeg).
#
# Usage:
#   ./zerocoder-download.sh <lesson-url> [output-dir]
#
# Requirements:
#   - monolith (https://github.com/Y2Z/monolith) — inlines all page assets
#   - curl
#   - ffmpeg
#   - python3
#   - pass entry: Hubbitus/zerocoder.ru
#
# Env tunables:
#   NO_TRANSCODE=1   — skip AV1 transcoding step
#   CRF / PRESET / AUDIO_KBPS / TRANSCODE_SAVE_ORIGINAL — passed to zerocoder-transcode.sh
#
set -euo pipefail

# Log all into file too
exec &> >( ts '%d-%H:%M:%.S' | ts -i -- '+%H:%M:%.S' | tee -i -- "$(basename $0).$(date --iso-8601=s).log" )

# Ensure cargo-installed binaries (monolith) are on PATH
export PATH="${HOME}/.cargo/bin:${PATH}"

URL="${1:?Usage: $0 <lesson-url> [output-dir]}"
OUT_DIR_EXPLICIT="${2:-}"
OUT_DIR="${OUT_DIR_EXPLICIT:-./downloaded}"
LOGIN_EMAIL="pahan@hubbitus.info"
PASS_ENTRY="Hubbitus/zerocoder.ru"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

HOST="$(echo "$URL" | awk -F/ '{print $3}')"
BASE="https://${HOST}"
LOGIN_PAGE="${BASE}/cms/system/login"
LOGIN_API="${BASE}/user/public/user/json"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
COOKIES="${WORK}/cookies.txt"
LOGIN_HTML="${WORK}/login.html"

for bin in curl monolith ffmpeg python3 pass; do
    command -v "$bin" >/dev/null || { echo "ERROR: $bin not found" >&2; exit 1; }
done

echo "==> Fetching password from pass: ${PASS_ENTRY}"
PASSWORD="$(pass show "${PASS_ENTRY}")"
[[ -n "${PASSWORD}" ]] || { echo "ERROR: empty password" >&2; exit 1; }

echo "==> Bootstrapping session"
curl -sS -c "${COOKIES}" "${LOGIN_PAGE}" -o "${LOGIN_HTML}"
CSRF="$(grep -oP 'csrfToken\s*=\s*"\K[^"]+' "${LOGIN_HTML}" | head -1 || true)"

echo "==> Authenticating as ${LOGIN_EMAIL}"
LOGIN_RESP="$(
    curl -sS -c "${COOKIES}" -b "${COOKIES}" \
        -H "X-Requested-With: XMLHttpRequest" \
        ${CSRF:+-H "X-CSRF-Token: ${CSRF}"} \
        --data-urlencode "email=${LOGIN_EMAIL}" \
        --data-urlencode "password=${PASSWORD}" \
        --data-urlencode "action=login" \
        "${LOGIN_API}"
)"
unset PASSWORD

echo "${LOGIN_RESP}" | grep -q '"success":true' \
    || { echo "ERROR: login failed. ${LOGIN_RESP}" >&2; exit 2; }
echo "==> Login OK: ${LOGIN_RESP}"

mkdir -p "${OUT_DIR}"

# Derive a stable basename from the URL path (last segment + query id if any)
URL_SLUG="$(echo "${URL}" | sed -E 's|.*/||; s|\?|_|; s|[^A-Za-z0-9._=-]|_|g')"
MAIN_HTML="${OUT_DIR}/${URL_SLUG}.html"
VIDEO_DIR="${OUT_DIR}/videos"
mkdir -p "${VIDEO_DIR}"

echo "==> Inlining page with monolith → ${MAIN_HTML}"
# monolith ignores curl's `#HttpOnly_` prefix as a comment — strip it.
COOKIES_FOR_MONOLITH="${WORK}/cookies_monolith.txt"
sed 's/^#HttpOnly_//' "${COOKIES}" > "${COOKIES_FOR_MONOLITH}"
monolith \
    --cookie-file "${COOKIES_FOR_MONOLITH}" \
    --user-agent "${UA}" \
    --no-js \
    --unwrap-noscript \
    --insecure \
    --ignore-errors \
    --timeout 60 \
    --output "${MAIN_HTML}" \
    "${URL}"

[[ -s "${MAIN_HTML}" ]] || { echo "ERROR: monolith produced empty HTML" >&2; exit 3; }
echo "==> Main HTML: ${MAIN_HTML} ($(du -h "${MAIN_HTML}" | cut -f1))"

echo "==> Scanning HTML for GCVH sign-player video links"
mapfile -t SIGN_URLS < <(
    python3 - "${MAIN_HTML}" <<'PYEOF'
import sys, re, html
data = open(sys.argv[1], encoding='utf-8').read()
urls = re.findall(r'https://[^"\'<>\s]+/sign-player/[^"\'<>\s]+', data)
out = set()
for u in urls:
    u = html.unescape(u)
    u = u.replace('/sign-player/index.html?', '/sign-player/?')
    out.add(u)
for u in sorted(out):
    print(u)
PYEOF
)
echo "==> Found ${#SIGN_URLS[@]} unique video player URLs"

idx=0
for SIGN_URL in "${SIGN_URLS[@]}"; do
    idx=$((idx+1))
    echo ""
    echo "==> [Video ${idx}/${#SIGN_URLS[@]}] ${SIGN_URL:0:120}..."

    PLAYER_HTML="${WORK}/player_${idx}.html"
    curl -sSL -b "${COOKIES}" \
        -H "Referer: ${BASE}/" \
        -A "${UA}" \
        "${SIGN_URL}" -o "${PLAYER_HTML}"

    # Extract video_hash for naming
    VIDEO_HASH="$(
        echo "${SIGN_URL}" \
            | grep -oP 'json=\K[^&]+' \
            | base64 -d 2>/dev/null \
            | python3 -c 'import sys,json; print(json.load(sys.stdin)["video_hash"])' \
            || echo "video_${idx}"
    )"

    # Get a fresh sign URL to prevent token expiration issues
    SIGN_URL="$(
        python3 - "${COOKIES}" "${UA}" "${URL}" "${VIDEO_HASH}" "${SIGN_URL}" <<'PYEOF'
import sys, re, html, json, base64, urllib.request, http.cookiejar
cookies_path, ua, lesson_url, video_hash, fallback_url = sys.argv[1:6]

cj = http.cookiejar.MozillaCookieJar()
try:
    cj.load(cookies_path, ignore_discard=True, ignore_expires=True)
except Exception:
    pass

opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
req = urllib.request.Request(lesson_url, headers={'User-Agent': ua})
try:
    with opener.open(req) as resp:
        html_content = resp.read().decode('utf-8')
except Exception:
    print(fallback_url)
    sys.exit(0)

urls = re.findall(r'https://[^"\'<>\s]+/sign-player/[^"\'<>\s]+', html_content)
for u in urls:
    u = html.unescape(u)
    m = re.search(r'json=([^&]+)', u)
    if m:
        try:
            b64 = m.group(1)
            b64 += "=" * ((4 - len(b64) % 4) % 4)
            decoded = json.loads(base64.b64decode(b64).decode('utf-8'))
            if decoded.get("video_hash") == video_hash:
                print(u.replace('/sign-player/index.html?', '/sign-player/?'))
                sys.exit(0)
        except Exception:
            pass

print(fallback_url)
PYEOF
    )"

    OUT_MP4="${VIDEO_DIR}/${VIDEO_HASH}.mp4"
    if [[ -s "${OUT_MP4}" ]]; then
        echo "  -> already downloaded: ${OUT_MP4}"
    else
        # Fetch master playlist and find the best working variant using python
        PICK_INFO="$(
            python3 - "${PLAYER_HTML}" "${SIGN_URL}" "${UA}" <<'PYEOF'
import sys, re, json, urllib.request, urllib.parse, time

player_html_path = sys.argv[1]
sign_url = sys.argv[2]
ua = sys.argv[3]

with open(player_html_path, encoding='utf-8') as f:
    player_html = f.read()

# Parse configs block
configs = {}
start_idx = player_html.find("window.configs =")
if start_idx == -1:
    start_idx = player_html.find("configs =")
if start_idx != -1:
    json_start = player_html.find("{", start_idx)
    if json_start != -1:
        try:
            decoder = json.JSONDecoder()
            configs, _ = decoder.raw_decode(player_html[json_start:])
        except Exception:
            pass

# Extract domains
domains = configs.get("masterPlaylistDomains", [])
if not domains:
    # Fallback to regex on masterPlaylistDomains
    m = re.search(r"masterPlaylistDomains\"\s*:\s*(\[[^\]]+\])", player_html)
    if m:
        try:
            domains = json.loads(m.group(1).replace("\\/", "/"))
        except Exception:
            pass

if not domains:
    # Try masterPlaylistUrl
    master_playlist_url = configs.get("masterPlaylistUrl")
    if master_playlist_url:
        domains = [master_playlist_url]
    else:
        sys.exit(1)

parsed_url = urllib.parse.urlparse(sign_url)
base_domain = f"{parsed_url.scheme}://{parsed_url.netloc}"

# Personalization trigger & polling
create_path = configs.get("createPersonalVideoUrl")
ready_path = configs.get("checkPersonalVideoUrl")
if create_path and ready_path:
    create_url = urllib.parse.urljoin(base_domain, create_path)
    ready_url = urllib.parse.urljoin(base_domain, ready_path)
    
    # Check if ready
    req_ready = urllib.request.Request(ready_url, headers={'User-Agent': ua, 'Referer': sign_url})
    is_ready = False
    try:
        with urllib.request.urlopen(req_ready) as resp:
            ready_resp = json.loads(resp.read().decode('utf-8'))
        is_ready = ready_resp.get("ready", False)
    except Exception:
        pass
        
    if not is_ready:
        # Trigger
        req_create = urllib.request.Request(create_url, data=b"", headers={'User-Agent': ua, 'Referer': sign_url})
        try:
            with urllib.request.urlopen(req_create) as resp:
                resp.read()
        except Exception:
            pass
            
        # Poll
        for _ in range(30):
            time.sleep(2)
            try:
                with urllib.request.urlopen(req_ready) as resp:
                    ready_resp = json.loads(resp.read().decode('utf-8'))
                if ready_resp.get("ready", False):
                    break
            except Exception:
                pass

def get_height(ln):
    res_match = re.search(r'RESOLUTION=(\d+)x(\d+)', ln)
    return int(res_match.group(2)) if res_match else 0

for master_url in domains:
    req = urllib.request.Request(master_url, headers={'User-Agent': ua, 'Referer': sign_url})
    try:
        with urllib.request.urlopen(req) as resp:
            master_content = resp.read().decode('utf-8')
    except Exception:
        continue

    variants = []
    lines = master_content.splitlines()
    for i, ln in enumerate(lines):
        if ln.startswith('#EXT-X-STREAM-INF'):
            height = get_height(ln)
            pick = lines[i+1].strip()
            v_url = urllib.parse.urljoin(master_url, pick)
            variants.append((height, v_url, ln))

    if not variants:
        continue

    # Sort preference: 720p preferred, then 1080p, then others descending
    def pref_key(v):
        h = v[0]
        if 700 <= h <= 750:
            return (0, -h)
        if 1000 <= h <= 1100:
            return (1, -h)
        return (2, -h)

    variants.sort(key=pref_key)

    for height, v_url, ln in variants:
        req_var = urllib.request.Request(v_url, headers={'User-Agent': ua, 'Referer': sign_url})
        try:
            with urllib.request.urlopen(req_var) as resp_var:
                var_content = resp_var.read().decode('utf-8')
            segments = [l for l in var_content.splitlines() if l.strip() and not l.startswith('#')]
            if len(segments) > 0:
                print(v_url)
                print(sign_url)
                print(f"{height}p")
                sys.exit(0)
        except Exception:
            pass

sys.exit(2)
PYEOF
        )" || { echo "  ERROR: no working stream found for ${VIDEO_HASH}" >&2; exit 4; }

        # Read the three lines from PICK_INFO
        mapfile -t PICK_ARR <<< "${PICK_INFO}"
        VARIANT_URL="${PICK_ARR[0]}"
        VARIANT_REFERER="${PICK_ARR[1]}"
        VARIANT_RESOLUTION="${PICK_ARR[2]}"

        echo "  -> Chosen variant: ${VARIANT_RESOLUTION} via Referer: ${VARIANT_REFERER}"
        attempt=1
        max_attempts=5
        download_ok=0
        while (( attempt <= max_attempts )); do
            echo "  -> ffmpeg HLS download → ${OUT_MP4} (Attempt ${attempt}/${max_attempts})"
            if ffmpeg -hide_banner -loglevel error -stats \
                -allowed_extensions ALL \
                -extension_picky 0 \
                -reconnect 1 \
                -reconnect_streamed 1 \
                -reconnect_delay_max 5 \
                -rw_timeout 10000000 \
                -f hls \
                -headers "Referer: ${VARIANT_REFERER}"$'\r\n' \
                -user_agent "${UA}" \
                -i "${VARIANT_URL}" \
                -c copy -bsf:a aac_adtstoasc \
                -y "${OUT_MP4}"; then
                download_ok=1
                break
            else
                echo "  WARN: ffmpeg failed on attempt ${attempt}" >&2
                rm -f "${OUT_MP4}"
                attempt=$((attempt+1))
                [[ ${attempt} -le ${max_attempts} ]] && sleep 5
            fi
        done
        if [[ "${download_ok}" != "1" ]]; then
            echo "  ERROR: ffmpeg failed for ${VIDEO_HASH} after ${max_attempts} attempts" >&2
            exit 5
        fi
    fi

    # Replace entire vhi-root <div> container (identified by data-video-hash)
    # with a local <video> tag. Container holds player iframe + GCVH metadata
    # attributes; matching by hash avoids touching unrelated markup.
    REL_VIDEO="videos/${VIDEO_HASH}.mp4"
    if [[ "${NO_TRANSCODE:-0}" != "1" ]]; then
        REL_VIDEO="videos/${VIDEO_HASH}.av1.webm"
    fi
    python3 - "${MAIN_HTML}" "${VIDEO_HASH}" "${REL_VIDEO}" <<'PYEOF'
import sys, re
path, video_hash, rel_video = sys.argv[1:4]
with open(path, encoding='utf-8') as f:
    content = f.read()
pattern = re.compile(
    r'<div\b[^>]*?\bdata-video-hash="' + re.escape(video_hash) + r'"[^>]*?>.*?</iframe>\s*</div>',
    re.DOTALL
)
replacement = (
    f'<video controls preload="metadata" style="width:100%;max-width:960px" '
    f'src="{rel_video}"></video>'
)
new_content, n = pattern.subn(replacement, content)
if n:
    with open(path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"  -> HTML patched ({n}x): {rel_video}")
else:
    print(f"  -> WARN: vhi-root div for {video_hash} not found")
PYEOF

done

if [[ "${NO_TRANSCODE:-0}" != "1" ]]; then
    echo ""
    echo "==> Transcoding videos to AV1 (libsvtav1) via zerocoder-transcode.sh"
    SAVE_ORIGINAL="${TRANSCODE_SAVE_ORIGINAL:-false}" \
        "$(dirname "$0")/zerocoder-transcode.sh" "${OUT_DIR}"
fi

# Create top-level symlink named after lesson title for easy access
TITLE="$(
    python3 -c '
import sys, re, html
d = open(sys.argv[1], encoding="utf-8").read()
m = re.search(r"<title>([^<]+)</title>", d)
print(html.unescape(m.group(1)).strip() if m else "")
' "${MAIN_HTML}"
)"

FINAL_DIR="${OUT_DIR}"
if [[ -z "${OUT_DIR_EXPLICIT}" && -n "${TITLE}" ]]; then
    # Sanitize: strip slashes/colons/control chars but keep cyrillic
    SAFE_TITLE="$(echo "${TITLE}" | tr '/:\\' '___' | tr -d '\r\n')"
    PARENT_DIR="$(dirname "${OUT_DIR}")"
    CANDIDATE="${PARENT_DIR}/${SAFE_TITLE}"
    if [[ -e "${CANDIDATE}" && "${CANDIDATE}" != "${OUT_DIR}" ]]; then
        echo "==> WARN: «${CANDIDATE}» exists, keeping «${OUT_DIR}»"
    else
        mv -T "${OUT_DIR}" "${CANDIDATE}"
        FINAL_DIR="${CANDIDATE}"
        MAIN_HTML="${FINAL_DIR}/${URL_SLUG}.html"
        echo "==> Renamed dir → «${FINAL_DIR}»"
    fi
fi

echo ""
echo "==> Done."
echo "==> Open: «${MAIN_HTML}»"
