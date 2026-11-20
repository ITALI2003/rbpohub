/* Агент OTA: скачивание образа (libcurl), распаковка (zlib), проверка подписи (OpenSSL). */
#include <curl/curl.h>
#include <zlib.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include "ota_agent.h"

int ota_download(const char *url, const char *dst)
{
    CURL *c = curl_easy_init();
    curl_easy_setopt(c, CURLOPT_URL, url);
    curl_easy_setopt(c, CURLOPT_SSL_VERIFYPEER, 1L);
    curl_easy_setopt(c, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1_3);
    CURLcode rc = curl_easy_perform(c);
    curl_easy_cleanup(c);
    (void)dst;
    return rc == CURLE_OK ? 0 : -1;
}

int ota_verify(const unsigned char *img, size_t len, const unsigned char *sig, size_t sig_len, EVP_PKEY *pub)
{
    EVP_MD_CTX *md = EVP_MD_CTX_new();
    int ok = EVP_DigestVerifyInit(md, NULL, NULL, NULL, pub) == 1 &&
             EVP_DigestVerify(md, sig, sig_len, img, len) == 1;   /* Ed25519 */
    EVP_MD_CTX_free(md);
    return ok ? 0 : -1;
}
