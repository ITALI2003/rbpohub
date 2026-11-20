/* Разбор заданий ЦСУД (JSON) */
#include <string.h>
#include "cJSON.h"
#include "task_parser.h"

int task_parse(const char *json, delivery_task_t *t)
{
    cJSON *root = cJSON_Parse(json);
    if (root == NULL) return -1;
    const cJSON *id = cJSON_GetObjectItemCaseSensitive(root, "task_id");
    const cJSON *route = cJSON_GetObjectItemCaseSensitive(root, "route");
    if (!cJSON_IsNumber(id) || !cJSON_IsArray(route)) { cJSON_Delete(root); return -1; }
    t->id = (unsigned)id->valuedouble;
    t->points = cJSON_GetArraySize(route);
    cJSON_Delete(root);
    return 0;
}
