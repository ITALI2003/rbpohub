# ЛР5. Формальная верификация модуля голосования арбитра TMR (робот-курьер, вариант 1)

Дисциплина: «Разработка безопасного программного обеспечения». Выполнила: Аитова А. В., гр. М3О-207СВ-25. Преподаватель: Горбунов М. М.

## Состав
- `src/legacy/vote_parser_legacy.c` — исходный модуль с 5 дефектами (CWE-190, 787, 369, 129, 476)
- `src/fixed/vote_parser.c` — исправленный модуль с ACSL-контрактами и инвариантами циклов
- `harness/harness.c` — обвязка для ESBMC (недетерминированный пакет 0..64 байт), `harness/harness_eva.c` — для Frama-C EVA
- `tests/repro.c` — воспроизведение контрпримеров ESBMC с ASan/UBSan
- `scripts/run_esbmc.sh`, `scripts/run_frama_c.sh`, `.gitlab-ci.yml`
- `results/` — логи прогонов

## Запуск (WSL2, Ubuntu 24.04)
Frama-C есть в репозитории Ubuntu 24.04; в Ubuntu 22.04 пакет удалён.
```bash
sudo apt install -y frama-c why3 alt-ergo z3 gcc unzip wget tree
why3 config detect
wget https://github.com/esbmc/esbmc/releases/download/v7.11/esbmc-linux.zip && unzip esbmc-linux.zip -d ~/esbmc
export ESBMC=$(find ~/esbmc -name esbmc -type f | head -1); chmod +x $ESBMC
./scripts/run_esbmc.sh all     # legacy: VERIFICATION FAILED (7), fixed: VERIFICATION SUCCESSFUL
./scripts/run_frama_c.sh all   # EVA-тревоги на legacy, WP-доказательство контрактов fixed
gcc -g -fsanitize=address,undefined -Isrc tests/repro.c src/legacy/vote_parser_legacy.c -o repro && ./repro 1
```
Frama-C через Docker (если apt не подходит):
```bash
export FRAMAC="docker run --rm -v $PWD:/work -w /work framac/frama-c:32.1 frama-c"
./scripts/run_frama_c.sh all
```
Если WP пишет, что решатель alt-ergo не найден: `why3 config list-provers` и `PROVER="<имя из списка>" ./scripts/run_frama_c.sh wp` (или `PROVER=z3`).
