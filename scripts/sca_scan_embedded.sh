#!/bin/bash
# Шаги 8 и 14. SCA-сканирование Trivy: lock-файлы conan и SBOM каждой прошивки
TRIVY="docker run --rm -v $(pwd):/src -w /src aquasec/trivy:latest"
for d in individual_work/*/; do
  n=$(basename "$d")
  echo "=== $n: trivy fs (conan.lock) ==="
  $TRIVY fs --scanners vuln --severity CRITICAL,HIGH,MEDIUM,LOW "$d" | tee "sca-$n-report.txt"
done
for f in individual_work/*/sbom_*.json; do $TRIVY sbom --severity CRITICAL,HIGH "$f"; done | tee sca-sbom-report.txt
$TRIVY fs --scanners vuln --severity CRITICAL --format table individual_work | tee sca-critical-report.txt
grep -h "Total:" sca-*-report.txt > sca-summary.md
cat sca-summary.md
