#!/bin/bash

# ============================================================
#   FUZZER – Created by Aryampillai
#   A lightweight recon + parameters + nuclei scanning tool
# ============================================================

banner() {
cat << "EOF"
 █████   █████ █████  █████ ██████   █████ ███████████ ██████████ ███████████  
░░███   ░░███ ░░███  ░░███ ░░██████ ░░███ ░█░░░███░░░█░░███░░░░░█░░███░░░░░███ 
 ░███    ░███  ░███   ░███  ░███░███ ░███ ░   ░███  ░  ░███  █ ░  ░███    ░███ 
 ░███████████  ░███   ░███  ░███░░███░███     ░███     ░██████    ░██████████  
 ░███░░░░░███  ░███   ░███  ░███ ░░██████     ░███     ░███░░█    ░███░░░░░███ 
 ░███    ░███  ░███   ░███  ░███  ░░█████     ░███     ░███ ░   █ ░███    ░███ 
 █████   █████ ░░████████   █████  ░░█████    █████    ██████████ █████   █████
░░░░░   ░░░░░   ░░░░░░░░   ░░░░░    ░░░░░    ░░░░░    ░░░░░░░░░░ ░░░░░   ░░░░░ 
                                                                               
                                                                                Created By Aryampillai
EOF
}

REQUIRED_TOOLS=("gau" "waybackurls" "uro" "gf" "paramspider" "httpx" "nuclei")

# ---- Tool Checker ----
check_tools() {
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if ! command -v $tool >/dev/null 2>&1; then
            echo "[ERROR] $tool is not installed."
            exit 1
        fi
    done
}

# ---- Usage ----
usage() {
    echo "Usage: $0 -u <target>"
    exit 1
}

# ---- Parameters ----
while getopts ":u:" opt; do
    case ${opt} in
        u ) TARGET=$OPTARG ;;
        * ) usage ;;
    esac
done

[ -z "$TARGET" ] && usage

# ---- Start ----
banner
check_tools

mkdir -p output
OUTDIR="output/$TARGET"
mkdir -p "$OUTDIR"

echo "[+] Collecting URLs using gau + waybackurls..."
( gau "$TARGET" && waybackurls "$TARGET" ) | uro | tee "$OUTDIR/urls.txt"

echo "[+] Extracting params using ParamSpider..."
paramspider --domain "$TARGET" -o "$OUTDIR/paramspider.txt"

echo "[+] Combining params..."
cat "$OUTDIR/urls.txt" "$OUTDIR/paramspider.txt" | uro > "$OUTDIR/clean_urls.txt"

echo "[+] Filtering interesting patterns with gf..."
for pattern in xss sqli redirect rce lfi ssrf; do
    gf $pattern < "$OUTDIR/clean_urls.txt" > "$OUTDIR/$pattern.txt"
done

echo "[+] Probing URLs using httpx..."
cat "$OUTDIR/clean_urls.txt" | httpx -silent -status-code -follow-redirects -threads 50 > "$OUTDIR/httpx_alive.txt"

echo "[+] Running nuclei for vulnerabilities..."
nuclei -l "$OUTDIR/httpx_alive.txt" -o "$OUTDIR/nuclei_results.txt"

echo "[✔] Done. Output saved in $OUTDIR/"
