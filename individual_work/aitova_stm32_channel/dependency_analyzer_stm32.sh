#!/bin/bash
# Шаг 6. Анализ зависимостей прошивки резервного канала (STM32H7 + FreeRTOS + lwIP + Mbed TLS)
echo "=== Анализ зависимостей прошивки канала 2/3 (STM32H7) ==="
find . -name "*.c" -o -name "*.h" | xargs grep -h "#include" | \
  grep -E "(mbedtls|lwip|FreeRTOS|task|queue|stm32)" | sort | uniq > stm32_dependencies.txt
grep -rn "mbedtls_ssl_\|MBEDTLS_SSL_TRANSPORT_DATAGRAM\|MBEDTLS_SSL_VERIFY" src > crypto_functions.txt
{
  echo "=== Критичные зависимости канала 2/3 ==="
  echo "1. Mbed TLS — DTLS-канал голосования к арбитру (UDP/8888), проверка сертификатов"
  echo "2. lwIP — сетевой стек: разбирает все входящие пакеты бортовой сети"
  echo "3. FreeRTOS — ядро РВ: очереди и задачи (сбой = остановка канала)"
  echo "4. STM32CubeH7 HAL, CMSIS, newlib — драйверы и runtime компилятора"
  echo "Пакетный менеджер: только Mbed TLS (conan.lock); остальное — исходники в репозитории"
} > report_stm32.txt
cat stm32_dependencies.txt; echo; echo "Вызовы Mbed TLS: $(wc -l < crypto_functions.txt)"; cat report_stm32.txt
