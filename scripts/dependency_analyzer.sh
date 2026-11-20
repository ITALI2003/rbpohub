#!/bin/bash
# Анализ зависимостей прошивок робота-курьера по директивам #include (C/C++ без пакетного менеджера)
echo "=== Анализ зависимостей проекта встраиваемой системы ==="
ROOT=${1:-.}
find "$ROOT" \( -name "*.c" -o -name "*.cpp" -o -name "*.h" \) -print0 | xargs -0 grep -h "#include" | \
  grep -E -i "(openssl|mbedtls|cjson|curl|sqlite|zlib|lwip|freertos|task\.h|queue\.h|stm32|cmsis|socket)" | \
  sed 's/[[:space:]]*$//' | sort | uniq -c | sort -rn > dependencies_analysis.txt
cat dependencies_analysis.txt
mkdir -p security
cat > security/critical_dependencies.list << 'LIST'
openssl
mbedtls
libcurl
cjson
sqlite3
zlib
lwip
freertos
arm-none-eabi-gcc
LIST
echo "Найдено уникальных директив: $(wc -l < dependencies_analysis.txt)"
echo "✅ Анализ зависимостей завершен"
