#!/bin/bash

# Usage
if [ -z "$1" ]; then
  echo "Usage: $0 <target.com> [--juicy] [--httpx]"
  exit 1
fi

domain=$1
API_KEY="YOUR_REDHUNTLABS_API_KEY"
JUICY_FILTER=false
USE_HTTPX=false

# Parse flags
for arg in "$@"; do
  case $arg in
    --juicy)
      JUICY_FILTER=true
      ;;
    --httpx)
      USE_HTTPX=true
      ;;
  esac
done

echo "[*] Collecting subdomains for $domain..."

# Collect all subdomains
all_subs=$(
  {
    subfinder -d "$domain" -silent
    curl -s "https://dns.bufferover.run/dns?q=.$domain" | jq -r .FDNS_A[] 2>/dev/null | cut -d',' -f2
    curl -s "https://riddler.io/search/exportcsv?q=pld:$domain" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+"
    curl -s --request GET "https://reconapi.redhuntlabs.com/community/v1/domains/subdomains?domain=$domain&page_size=1000" \
      --header "X-BLOBR-KEY: $API_KEY" | jq -r '.subdomains[]' 2>/dev/null
    curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g'
    curl -s "https://api.threatminer.org/v2/domain.php?q=$domain&rt=5" | jq -r '.results[]' | grep -o "\w.*$domain"
    curl -s "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$domain" | jq -r '.subdomains[]' 2>/dev/null
    curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" | cut -d',' -f1
    curl -s "https://jldc.me/anubis/subdomains/$domain" | grep -o "\w.*$domain"
    curl -s "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" \
      | jq .[].dns_names | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+"
    curl -s "http://web.archive.org/cdx/search/cdx?url=*.$domain/*&output=text&fl=original&collapse=urlkey" \
      | sed -e 's_https*://__' -e "s/\/.*//"
    curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/url_list?limit=100&page=1" \
      | grep -o '"hostname": *"[^"]*' | sed 's/"hostname": "//'
    curl -s "https://api.subdomain.center/?domain=$domain" | jq -r '.[]' 2>/dev/null
    censys subdomains "$domain" 2>/dev/null
  } | sed "s/^www\.//" | sort -u
)

total=$(echo "$all_subs" | wc -l)
echo "[*] Total unique subdomains found: $total"

# Filter juicy subdomains
if $JUICY_FILTER; then
  echo "[*] Filtering juicy subdomains..."
  all_subs=$(echo "$all_subs" | grep -Ei 'api|dev|admin|test|stage|vpn|stg|pre|demo')
  echo "[*] Total juicy subdomains: $(echo "$all_subs" | wc -l)"
fi

# Probing live subdomains with httpx
if $USE_HTTPX; then
  echo "[*] Probing for live hosts with httpx..."
  echo "$all_subs" | httpx -silent -title -status-code -content-length
else
  echo "$all_subs"
fi
