#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file_with_domains> <output_file>"
    exit 1
fi

FILE="$1"
OUTPUT_FILE="$2"

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

> "$OUTPUT_FILE"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

function open_url_in_chrome {
    local url=$1
    open -a "Google Chrome" "$url"
}

TARGETS=("/.git/" "/.env" "/.env.example" "/.ssh/id_rsa" "/.ssh/id_rsa.pub")

while IFS= read -r DOMAIN; do
    if [ -z "$DOMAIN" ]; then
        continue
    fi

    for TARGET in "${TARGETS[@]}"; do
        URL="${DOMAIN}${TARGET}"
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$URL")

        if [ $? -ne 0 ]; then
            echo -e "${RED}TIMEOUT: $URL${NC}"
            continue
        fi

        if [ "$RESPONSE" -eq 200 ]; then
            echo -e "${GREEN}VULN: $URL${NC}"
            echo "VULN: $URL" >> "$OUTPUT_FILE"
            if [[ "$TARGET" == ".git/" ]]; then
                open_url_in_chrome "${DOMAIN}.git/info"
            fi
        elif [ "$RESPONSE" -eq 403 ]; then
            echo -e "${GREEN}MAYBE VULN: $URL${NC}"
            echo "MAYBE VULN: $URL" >> "$OUTPUT_FILE"
        else
            echo -e "${RED}SAFE: $URL${NC}"
        fi
    done
done < "$FILE"

