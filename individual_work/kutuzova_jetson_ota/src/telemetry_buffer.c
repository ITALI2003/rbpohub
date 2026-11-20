/* Буфер телеметрии на время потери связи (SQLite) */
#include <sqlite3.h>
#include "telemetry_buffer.h"

static sqlite3 *db;

int telemetry_buffer_open(const char *path)
{
    if (sqlite3_open(path, &db) != SQLITE_OK) return -1;
    return sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS t(ts INTEGER, x REAL, y REAL, battery INTEGER)", 0, 0, 0);
}
