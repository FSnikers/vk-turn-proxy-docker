# Good TURN
Проброс трафика WireGuard/Hysteria через TURN сервера VK звонков или Яндекс телемоста. Пакеты шифруются DTLS 1.2, затем параллельными потоками через TCP или UDP отправляются на TURN сервер по протоколу STUN ChannelData. Оттуда по UDP отправляются на ваш сервер, где расшифровываются и передаются в WireGuard. Логин/пароль от TURN генерируются из ссылки на звонок.

Только для учебных целей!
## Настройка
Нам понадобится:
1. Ссылка на действующий ВК звонок: создаём свой (нужен аккаунт вк), или гуглим `"https://vk.com/call/join/"`.
Ссылка действительна вечно, если не нажимать "завершить звонок для всех"
2. Или ссыска на звонок Яндекс телемоста: `"https://telemost.yandex.ru/j/"`. Её лучше не гуглить, так как видно подключение к конференции
3. VPS с установленным WireGuard
4. Для андроида: скачать Termux из F-Droid
### Сервер
```
./server -listen 0.0.0.0:56000 -connect 127.0.0.1:<порт wg>
```
### Клиент
#### Android

**Рекомендуемый способ:**
Использовать нативное Android-приложение [vk-turn-proxy-android](https://github.com/MYSOREZ/vk-turn-proxy-android).
- В клиентском конфиге WireGuard меняем адрес сервера на `127.0.0.1:9000`, ставим MTU 1280
-  **Добавляем приложение в исключения WireGuard. Нажимаем "сохранить".**

**Альтернативный способ (через Termux):**
- В клиентском конфиге WireGuard меняем адрес сервера на `127.0.0.1:9000`, ставим MTU 1280
-  **Добавляем Termux в исключения WireGuard. Нажимаем "сохранить".**
В Termux:
```
termux-wake-lock
```
Телефон не будет уходить в глубокий сон, так что на ночь ставьте на зарядку. Чтобы отключить:
```
termux-wake-unlock
```
Копируем бинарник в локальную папку, даём права на исполнение:
```
cp /sdcard/Download/client-android ./
chmod 777 ./client-android
```
Запускаем:
```
./client-android -peer <ip сервера wg>:56000 -vk-link <VK ссылка> -listen 127.0.0.1:9000
```
Или
```
./client-android -udp -turn 5.255.211.241 -peer <ip сервера wg>:56000 -yandex-link <Ya ссылка> -listen 127.0.0.1:9000
```

**Если после включения VPN в терминале вылезают ошибки DNS, попробуйте в Wireguard включить VPN только для нужных приложений.**
#### Linux
В клиентском конфиге WireGuard меняем адрес сервера на `127.0.0.1:9000`, ставим MTU 1280

Скрипт будет добавлять маршруты к нужным ip:

```
./client-linux -peer <ip сервера wg>:56000 -vk-link <VK ссылка> -listen 127.0.0.1:9000 | sudo routes.sh
```

```
./client-linux -udp -turn 5.255.211.241 -peer <ip сервера wg>:56000 -yandex-link <Ya ссылка> -listen 127.0.0.1:9000 | sudo routes.sh
```

Не включайте впн, пока программа не установит соединение! В отличие от андроида, здесь часть запросов будет идти через впн (dns и запрос подключения к turn)
#### Windows
В клиентском конфиге WireGuard меняем адрес сервера на `127.0.0.1:9000`, ставим MTU 1280

В PowerShell от Администратора (чтобы скрипт прописывал маршруты):

```
./client.exe -peer <ip сервера wg>:56000 -vk-link <VK ссылка> -listen 127.0.0.1:9000 | routes.ps1
```

```
./client.exe -udp -turn 5.255.211.241 -peer <ip сервера wg>:56000 -yandex-link <Ya ссылка> -listen 127.0.0.1:9000 | routes.ps1
```

Не включайте впн, пока программа не установит соединение! В отличие от андроида, здесь часть запросов будет идти через впн (dns и запрос подключения к turn)
### Если не работает
С помощью опции `-turn` можно указать адрес TURN сервера вручную. Это должен быть сервер ВК, Макса или Одноклассников (ссылка вк) или Яндекса (ссылка яндекса). Возможно потом составлю список.

Если не работает TCP, попробуйте добавить флаг `-udp`.

Добавьте флаг `-n 1` для более стабильного подключения в 1 поток (ограничение 5 Мбит/с для ВК)

## Яндекс телемост
**UPD. ТЕЛЕМОСТ ЗАКРЫЛИ**

В отличие от ВК, сервера яндекса не ограничивают скорость, так что по умолчанию стоит `-n 1`. Увеличение этого числа может привести к временной блокировке по IP из-за переполнения конференции фейковыми участниками.

В режиме `-udp` скорость обычно больше

Большинство диапазонов IP TURN серверов Яндекса не работают, указывайте вручную через `-turn`
<details>
    <summary>
        Рабочие IP
    </summary>


    5.255.211.241
    5.255.211.242
    5.255.211.243
    5.255.211.245
    5.255.211.246


</details>
Спасибо https://github.com/KillTheCensorship/Turnel за часть кода :)

## v2ray

Вместо WireGuard можно использовать любое V2Ray-ядро которое его поддерживает (например, xray или sing-box) и любой V2Ray-клиент который использует это ядро (например, v2rayN или v2rayNG). С помощью их вы сможете добавить больше входящих интерфейсов (например, SOCKS) и реализовать точечный роутинг.

Пример конфигов:

<details>

<summary>
Клиент
</summary>

```json
{
    "inbounds": [
        {
            "protocol": "socks",
            "listen": "127.0.0.1",
            "port": 1080,
            "settings": {
                "udp": true
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        },
        {
            "protocol": "http",
            "listen": "127.0.0.1",
            "port": 8080,
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "wireguard",
            "settings": {
                "secretKey": "<client secret key>",
                "peers": [
                    {
                        "endpoint": "127.0.0.1:9000",
                        "publicKey": "<server public key>"
                    }
                ],
                "domainStrategy": "ForceIPv4",
                "mtu": 1280
            }
        }
    ]
}
```

</details>

<details>

<summary>
Сервер
</summary>

```json
{
    "inbounds": [
        {
            "protocol": "wireguard",
            "listen": "0.0.0.0",
            "port": 51820,
            "settings": {
                "secretKey": "<server secret key>",
                "peers": [
                    {
                        "publicKey": "<client public key>"
                    }
                ],
                "mtu": 1280
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIPv4"
            }
        }
    ]
}
```

</details>

## Direct mode
С флагом `-no-dtls` можно отправлять пакеты без обфускации DTLS и подключаться к обычным серверам Wireguard. Может привести к бану от вк/яндекса.


## Docker deployment: server 1 + server 2

Ниже готовая схема именно под ваш сценарий:

- **Сервер 1** поднимает `client` и слушает публичный UDP-порт WireGuard, например `51820/udp`.
- **Сервер 2** поднимает `server`, принимает трафик от сервера 1 на `56000/udp` и передаёт его в локальный WireGuard-контейнер.
- WireGuard-клиенты подключаются к **серверу 1**, а реальные WireGuard-сессии завершаются на **сервере 2**.

### Файлы

- `Dockerfile` — общий multi-stage build для `client` и `server`
- `deploy/server1/docker-compose.yml` — compose для сервера 1
- `deploy/server2/docker-compose.yml` — compose для сервера 2
- `deploy/server1/.env.example` и `deploy/server2/.env.example` — шаблоны переменных окружения

### Запуск на сервере 1

```bash
cd deploy/server1
cp .env.example .env
# отредактируйте PEER_ADDR и VK_LINK
docker compose up -d --build
```

Что нужно указать:

- `PEER_ADDR` — публичный IP/домен **сервера 2** с портом `56000`, например `203.0.113.20:56000`
- `VK_LINK` — ссылка на VK Calls
- `WG_PUBLIC_PORT` — UDP-порт, на который будут подключаться ваши WireGuard-клиенты

### Запуск на сервере 2

```bash
cd deploy/server2
cp .env.example .env
# обязательно выставьте SERVERURL равным публичному IP или DNS сервера 1
docker compose up -d --build
```

Ключевой момент:

- `SERVERURL` в контейнере WireGuard на **сервере 2** должен указывать на **сервер 1**, потому что клиенты подключаются именно туда.
- `CONNECT_ADDR=127.0.0.1:51820` оставляет `vk-turn-proxy server` привязанным к локальному WireGuard-контейнеру.

### Схема трафика

```text
WireGuard client
    |
    | UDP 51820
    v
Server 1: vk-turn-proxy client (Docker)
    |
    | WebRTC/TURN over VK
    v
Server 2: vk-turn-proxy server (Docker)
    |
    | UDP 51820
    v
Server 2: WireGuard container
```

### Примечания

- На **сервере 1** нужно открыть входящий UDP-порт WireGuard, обычно `51820/udp`.
- На **сервере 2** нужно открыть входящий UDP-порт `56000/udp` для `vk-turn-proxy server`.
- Если TCP-режим TURN работает нестабильно, на сервере 1 можно переключить `TRANSPORT_MODE=udp`.
- Если хотите использовать существующий WireGuard на сервере 2 вне Docker, можно не запускать контейнер `wireguard`, а задать `CONNECT_ADDR` на адрес уже существующего сервиса.
