#!/bin/bash
# Проверка лицензий компонентов по политике security/team_vulnerability_policy.yaml (OSS4)
SBOM=${1:-sbom_combined.json}
POLICY=security/team_vulnerability_policy.yaml
list() { awk -v k="$1:" '$1==k{f=1;next} f&&$1=="-"{if(match($0,/"[^"]+"/))print substr($0,RSTART+1,RLENGTH-2);next} f{f=0}' "$POLICY"; }
ALLOWED=$(list allowed_licenses)
EXCEPT=$(list approved_exceptions)
fail=0
echo "=== Проверка лицензий ($SBOM) ==="
while IFS=$'\t' read -r name ver lic; do
  if echo "$ALLOWED" | grep -qx "$lic"; then st="OK"
  elif echo "$EXCEPT" | grep -qx "$lic"; then st="OK (исключение, согласовано)"
  else st="ЗАПРЕЩЕНА"; fail=1; fi
  printf "%-40s %-10s %-14s %s\n" "$name" "$ver" "$lic" "$st"
done < <(jq -r '.. | objects | select(.type? == "library") | [.name, .version, (.licenses[0].license.id // "UNKNOWN")] | @tsv' "$SBOM")
[ $fail -eq 0 ] && echo "✅ Лицензионная проверка пройдена" || { echo "❌ Найдены неразрешённые лицензии"; exit 1; }
