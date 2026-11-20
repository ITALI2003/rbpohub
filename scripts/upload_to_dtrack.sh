#!/bin/bash
# Загрузка SBOM в Dependency-Track (проект создаётся автоматически). Ключ API: Administration → Access Management → Teams → Automation
DT=${DTRACK_URL:-http://localhost:8081}
for f in individual_work/*/sbom_*.json; do
  name=$(jq -r '.metadata.component.name' "$f"); ver=$(jq -r '.metadata.component.version' "$f")
  curl -s -X POST "$DT/api/v1/bom" -H "X-Api-Key: ${DTRACK_API_KEY:?задайте DTRACK_API_KEY}" \
    -F "autoCreate=true" -F "projectName=$name" -F "projectVersion=$ver" -F "bom=@$f"; echo " <- $name"
done
