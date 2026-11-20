/* Прошивка резервного канала TMR робота-курьера (канал 2/3, STM32H7, FreeRTOS).
 * Задачи: приём задания от ЦСУД, расчёт управляющего воздействия, отправка голоса арбитру. */
#include "stm32h7xx_hal.h"
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "lwip/tcpip.h"
#include "lwip/netif.h"
#include "vote_client.h"
#include "control.h"

#define VOTE_PERIOD_MS 10U          /* голосование 100 Гц (FR-04) */

static QueueHandle_t sensor_q;

static void vote_task(void *arg)
{
    (void)arg;
    TickType_t last = xTaskGetTickCount();
    control_cmd_t cmd;
    for (;;) {
        control_compute(&cmd);                /* решение канала */
        vote_client_send(&cmd);               /* DTLS 1.2, UDP/8888 -> 192.168.1.100 */
        vTaskDelayUntil(&last, pdMS_TO_TICKS(VOTE_PERIOD_MS));
    }
}

int main(void)
{
    HAL_Init();
    tcpip_init(NULL, NULL);
    sensor_q = xQueueCreate(16, sizeof(sensor_frame_t));
    vote_client_init("192.168.1.100", 8888);
    xTaskCreate(vote_task, "vote", 1024, NULL, configMAX_PRIORITIES - 1, NULL);
    vTaskStartScheduler();
    for (;;) { }
}
