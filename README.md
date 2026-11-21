# ЛР3. Композиционный анализ (SCA) прошивок робота-курьера

Дисциплина: «Разработка безопасного программного обеспечения». Гр. М3О-207СВ-25.
Аитова А. В. (DevSecOps, прошивка каналов 2/3 на STM32H7), Кутузова О. С. (аналитик SCA, канал 1 и OTA на Jetson).
Преподаватель: Горбунов М. М.

## Запуск

```bash
docker compose up -d                      # Dependency-Track: http://localhost:8080 (admin/admin)
./scripts/dependency_analyzer.sh individual_work
./scripts/generate_embedded_sbom.sh individual_work/aitova_stm32_channel/third_party.txt robot-ch2-ch3-stm32 "Robot TMR backup channel (STM32H7)" 1.0.0 individual_work/aitova_stm32_channel/sbom_stm32.json
./scripts/generate_embedded_sbom.sh individual_work/kutuzova_jetson_ota/third_party.txt robot-ch1-jetson "Robot TMR main channel + OTA agent (Jetson)" 1.0.0 individual_work/kutuzova_jetson_ota/sbom_jetson.json
./scripts/merge_sbom.sh
./scripts/check_licenses.sh sbom_combined.json
./scripts/sca_scan_embedded.sh            # trivy в docker
export DTRACK_API_KEY=...; ./scripts/upload_to_dtrack.sh
./scripts/dependency_monitor.sh
```

## Состав
- `individual_work/aitova_stm32_channel/` — исходники, third_party.txt, conan.lock, SBOM каналов 2/3
- `individual_work/kutuzova_jetson_ota/` — исходники, conan.lock, SBOM канала 1 и OTA
- `scripts/` — анализ, генерация и слияние SBOM, лицензии, Trivy, Dependency-Track, мониторинг
- `security/` — политика `team_vulnerability_policy.yaml`, список критичных зависимостей
- `.gitlab-ci.yml` — стадии build → sca → security_gate (+ ручная загрузка в DT)
- `results/` — выводы скриптов, `report/` — отчёт
добавлено