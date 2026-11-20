#!/bin/bash
# Шаг 10. Объединение индивидуальных SBOM в мастер-SBOM проекта
set -e
OUT=${1:-sbom_combined.json}; shift || true
FILES=${@:-individual_work/*/sbom_*.json}
jq -s --arg uuid "urn:uuid:$(cat /proc/sys/kernel/random/uuid)" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '{
  bomFormat: "CycloneDX", specVersion: "1.4", serialNumber: $uuid, version: 1,
  metadata: {timestamp: $ts, component: {type: "application", "bom-ref": "robot-courier-firmware-suite",
    name: "Robot Courier Firmware Suite", version: "1.0.0", description: "Прошивки каналов TMR робота-курьера"}},
  components: (map(.metadata.component + {components: .components}) )}' $FILES > "$OUT"
echo "Мастер-SBOM: $OUT; прошивок: $(jq '.components|length' $OUT); библиотек: $(jq '[.components[].components[]]|length' $OUT)"
