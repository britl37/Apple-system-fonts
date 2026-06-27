#!/usr/bin/env bash
# extract_fonts.sh — Extract .otf/.ttf fonts from Apple .dmg files
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${1:-$SCRIPT_DIR/extracted_fonts}"

RED="\x1B[31m"
GREEN="\x1B[32m"
YELLOW="\x1B[33m"
BOLD="\x1B[1m"
RESET="\x1B[0m"

err()    { echo -e "${RED}${BOLD}[ERROR]${RESET} $*" >&2; }
ok()     { echo -e "${GREEN}${BOLD}[OK]${RESET} $*"; }
warn()   { echo -e "${YELLOW}${BOLD}[WARN]${RESET} $*"; }
info()   { echo -e "${BOLD}[INFO]${RESET} $*"; }

# ── Prerequisites ──────────────────────────────────────────────
check_prerequisite() {
    local cmd="$1"
    local msg="${2:-}"

    if command -v "$cmd" > /dev/null 2>&1; then
        ok "Found: $cmd"
        return 0
    fi

    err "Missing dependency: $cmd"
    if [ -n "$msg" ]; then
        echo "  → $msg" >&2
    fi
    return 1
}

check_all_prerequisites() {
    local failures=0

    info "Checking prerequisites..."

    check_prerequisite "7z" \
        "Install p7zip:  sudo apt install p7zip-full" \
        || failures=$((failures + 1))

    check_prerequisite "realpath" \
        "Install coreutils:  sudo apt install coreutils" \
        || failures=$((failures + 1))

    if [ $failures -gt 0 ]; then
        err "$failures prerequisite(s) missing. Install them and retry."
        echo ""
        exit 1
    fi

    ok "All prerequisites satisfied."
    echo ""
}

# ── Extraction ─────────────────────────────────────────────────
# Prints count to stdout, returns non-zero on hard failure.
extract_fonts_from_dmg() {
    local dmg="$1"
    local tmp count=0

    info "Processing: $(basename "$dmg")"

    tmp="$(mktemp -d)"
    # shellcheck disable=SC2064
    trap "rm -rf '$tmp'" RETURN

    # Step 1: Extract DMG contents
    if ! 7z x "$dmg" -o"$tmp" -bd > /dev/null 2>&1; then
        err "Failed to extract DMG: $(basename "$dmg")"
        rm -rf "$tmp"
        echo "0"
        return 1
    fi

    # Step 2: Extract any .pkg files found
    while IFS= read -r -d '' pkg; do
        7z x "$pkg" -o"$tmp" -bd > /dev/null 2>&1 || true
    done < <(find "$tmp" -name "*.pkg" -print0)

    # Step 3: Extract Payload files (Apple pkgs use both "Payload" and "Payload~")
    for payload_name in "Payload" "Payload~"; do
        while IFS= read -r -d '' payload; do
            7z x "$payload" -o"$tmp" -bd > /dev/null 2>&1 || true
        done < <(find "$tmp" -name "$payload_name" -print0)
    done

    # Step 4: Collect all .otf/.ttf files (with path-traversal guard)
    while IFS= read -r -d '' font; do
        local real_font real_tmp
        real_font="$(realpath "$font")"
        real_tmp="$(realpath "$tmp")"
        if [[ "$real_font" != "$real_tmp"* ]]; then
            warn "Skipping suspicious path: $font"
            continue
        fi
        mv -f "$font" "$OUTPUT_DIR/"
        count=$((count + 1))
    done < <(find "$tmp" -type f \( -name "*.otf" -o -name "*.ttf" \) -print0)

    ok "Extracted $count font(s) from $(basename "$dmg")"
    rm -rf "$tmp"
    trap - RETURN

    echo "$count"
    return 0
}

# ── Main ───────────────────────────────────────────────────────
check_all_prerequisites

# Find all .dmg files
shopt -s nullglob
dmgs=("$SCRIPT_DIR"/*.dmg)
shopt -u nullglob

if [ ${#dmgs[@]} -eq 0 ]; then
    err "No .dmg files found in $SCRIPT_DIR"
    err "Place your .dmg files in the same directory as this script."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

info "Found ${#dmgs[@]} .dmg file(s). Extracting to: $OUTPUT_DIR"
echo ""

total_fonts=0
success=0
fail=0

for dmg in "${dmgs[@]}"; do
    # Capture count; detect failure via return code
    count="$(extract_fonts_from_dmg "$dmg")" && rc=0 || rc=$?
    total_fonts=$((total_fonts + count))
    if [ "$rc" -eq 0 ]; then
        success=$((success + 1))
    else
        fail=$((fail + 1))
    fi
done

echo ""
info "Done. $success succeeded, $fail failed. Total fonts extracted: $total_fonts"
exit $fail
