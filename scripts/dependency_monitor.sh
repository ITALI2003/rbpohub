#!/bin/bash
# Шаг 13. Мониторинг критичных зависимостей: повторное сканирование SBOM свежей базой Trivy + метрики Dependency-Track
echo "=== Мониторинг зависимостей ($(date -u +%F)) ==="
for f in individual_work/*/sbom_*.json; do
  docker run --rm -v $(pwd):/src -w /src aquasec/trivy:latest sbom --quiet --severity CRITICAL,HIGH --format json "$f"
done | jq -r '.Results[]?.Vulnerabilities[]? | "\(.PkgName) \(.InstalledVersion) \(.VulnerabilityID) \(.Severity) -> \(.FixedVersion)"' | sort -u
if [ -n "$DTRACK_API_KEY" ]; then
  curl -s "${DTRACK_URL:-http://localhost:8081}/api/v1/project" -H "X-Api-Key: $DTRACK_API_KEY" | \
    jq -r '.[] | "\(.name) \(.version): critical=\(.metrics.critical) high=\(.metrics.high) medium=\(.metrics.medium)"'
fi
