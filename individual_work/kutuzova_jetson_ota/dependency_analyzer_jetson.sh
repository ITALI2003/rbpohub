#!/bin/bash
# Шаг 6. Анализ зависимостей основного канала и OTA-агента (Jetson Xavier, Linux)
echo "=== Анализ зависимостей канала 1 / OTA-агента (Jetson) ==="
find . -name "*.c" -o -name "*.h" | xargs grep -h "#include" | \
  grep -E "(openssl|curl|cJSON|sqlite|zlib)" | sort | uniq > jetson_dependencies.txt
grep -rn "SSL_CTX_\|EVP_Digest\|curl_easy_\|cJSON_Parse\|sqlite3_open" src > crypto_functions.txt
{
  echo "=== Критичные зависимости канала 1 / OTA ==="
  echo "1. OpenSSL — mTLS к ЦСУД (TCP/443) и проверка подписи прошивок"
  echo "2. libcurl — загрузка OTA-образов (TCP/8443)"
  echo "3. zlib — распаковка образов; cJSON — разбор заданий; SQLite — буфер телеметрии"
  echo "Пакетный менеджер: conan (conan.lock) — все 5 компонентов видны сканерам"
} > report_jetson.txt
cat jetson_dependencies.txt; echo; echo "Вызовы библиотек: $(wc -l < crypto_functions.txt)"; cat report_jetson.txt
