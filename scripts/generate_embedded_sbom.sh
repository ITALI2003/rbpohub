#!/bin/bash
# Генерация SBOM CycloneDX 1.4 из списка компонентов third_party.txt
# usage: generate_embedded_sbom.sh <third_party.txt> <bom-ref> <название прошивки> <версия> <out.json>
set -e
IN=$1; REF=$2; NAME=$3; VER=$4; OUT=$5
UUID=$(cat /proc/sys/kernel/random/uuid)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
grep -v '^#' "$IN" | grep -v '^\s*$' | jq -R -s '
  split("\n") | map(select(length > 0) | split(";")) |
  map({type: "library", "bom-ref": .[3], name: .[0], version: .[1], purl: .[3],
       licenses: [{license: {id: .[2]}}]} + (if (.[4] // "") != "" then {cpe: .[4]} else {} end))' > /tmp/components.$$.json
jq -n --arg uuid "urn:uuid:$UUID" --arg ts "$TS" --arg ref "$REF" --arg name "$NAME" --arg ver "$VER" \
  --slurpfile comps /tmp/components.$$.json '{
  bomFormat: "CycloneDX", specVersion: "1.4", serialNumber: $uuid, version: 1,
  metadata: {timestamp: $ts, component: {type: "firmware", "bom-ref": $ref, name: $name, version: $ver}},
  components: $comps[0]}' > "$OUT"
rm -f /tmp/components.$$.json
echo "SBOM: $OUT ($(jq '.components | length' "$OUT") компонентов)"
