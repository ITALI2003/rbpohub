/* Клиент голосования: DTLS поверх lwIP, взаимная аутентификация по сертификату канала. */
#include <string.h>
#include "lwip/sockets.h"
#include "mbedtls/ssl.h"
#include "mbedtls/net_sockets.h"
#include "mbedtls/ctr_drbg.h"
#include "mbedtls/entropy.h"
#include "mbedtls/x509_crt.h"
#include "mbedtls/timing.h"
#include "vote_client.h"

static mbedtls_ssl_context ssl;
static mbedtls_ssl_config conf;
static mbedtls_x509_crt ca, own_cert;
static mbedtls_pk_context own_key;
static mbedtls_ctr_drbg_context drbg;
static mbedtls_entropy_context entropy;
static uint32_t cycle;               /* монотонный номер цикла (NFR-06) */

int vote_client_init(const char *arbiter_ip, int port)
{
    mbedtls_ssl_init(&ssl);
    mbedtls_ssl_config_init(&conf);
    mbedtls_ssl_config_defaults(&conf, MBEDTLS_SSL_IS_CLIENT,
                                MBEDTLS_SSL_TRANSPORT_DATAGRAM, MBEDTLS_SSL_PRESET_DEFAULT);
    mbedtls_ssl_conf_authmode(&conf, MBEDTLS_SSL_VERIFY_REQUIRED);
    mbedtls_ssl_conf_ca_chain(&conf, &ca, NULL);
    mbedtls_ssl_conf_own_cert(&conf, &own_cert, &own_key);
    mbedtls_ssl_conf_rng(&conf, mbedtls_ctr_drbg_random, &drbg);
    (void)arbiter_ip; (void)port;
    return mbedtls_ssl_setup(&ssl, &conf);
}

int vote_client_send(const control_cmd_t *cmd)
{
    uint8_t pkt[32];
    memcpy(pkt, &cycle, sizeof cycle);
    memcpy(pkt + 4, cmd, sizeof *cmd);
    cycle++;
    return mbedtls_ssl_write(&ssl, pkt, 4 + sizeof *cmd);
}
