/* Основной канал TMR (канал 1, Jetson Xavier, Linux): приём заданий от ЦСУД по mTLS,
 * голосование, буфер телеметрии, агент OTA-обновлений для всех трёх каналов. */
#include <stdio.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include "task_parser.h"
#include "ota_agent.h"
#include "telemetry_buffer.h"

int main(void)
{
    SSL_CTX *ctx = SSL_CTX_new(TLS_client_method());
    SSL_CTX_set_min_proto_version(ctx, TLS1_3_VERSION);
    SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, NULL);          /* mTLS к ЦСУД 10.20.30.10:443 */
    SSL_CTX_use_certificate_file(ctx, "/etc/robot/ch1.crt", SSL_FILETYPE_PEM);
    SSL_CTX_use_PrivateKey_file(ctx, "/etc/robot/ch1.key", SSL_FILETYPE_PEM);
    telemetry_buffer_open("/var/lib/robot/telemetry.db");
    ota_agent_start("https://10.20.30.30:8443/firmware");
    task_loop(ctx);
    return 0;
}
