# A Docker [DmarcSrg](https://github.com/liuch/dmarc-srg#readme) image

This image uses:

- Alpine as a base image (`webdevops/php-nginx:8.2-alpine`)
- Nginx as a web server with PHP-FPM

Tables will be prefixed with: `dmarc-srg_` by default.
And require a `DMARC` IMAP folder with unread reports.
That will be moved to `DMARC-PROCESSED.Aggregate` or `DMARC-PROCESSED.Invalid`.

## TODO

- HTTPS support

### Supported ENVs

- `DB_HOST` (The database host)
- `DB_NAME` (The database name)
- `DB_USER` (The database username)
- `DB_PASSWORD` (The database password)
- `IMAP_HOST` (The IMAP host)
- `IMAP_USER` (The IMAP user)
- `IMAP_PASSWORD` (The IMAP password)
- `UI_PASSWORD` (The web UI password)

#### For `utils/summary_report.php`

- `MAILER_FROM` (An email)
- `MAILER_DEFAULT` (An email)

## Usage

```yml
version: "2.3"

services:

    dmarc-srg:
        image: docker.io/botsudo/docker-dmarc-srg
        container_name: dmarc-srg
        user: application
        # If you want to mount a custom config and skip the ENVs
        #volumes:
        #  - ./config.php:/var/www/html/config/conf.php:ro
        healthcheck:
            test:
                [
                    "CMD",
                    "curl",
                    "-s",
                    "--fail",
                    "http://127.0.0.1/.nginx/status",
                ]
            start_period: 5s
            interval: 15s
            timeout: 1s
        environment:
            DB_HOST: $DMARC_SRG_DB_HOST
            DB_NAME: $DMARC_SRG_DB_NAME
            DB_USER: $DMARC_SRG_DB_USER
            DB_PASSWORD: $DMARC_SRG_DB_PASSWORD
            IMAP_HOST: $DMARC_SRG_IMAP_HOST
            IMAP_USER: $DMARC_SRG_IMAP_USER
            IMAP_PASSWORD: $DMARC_SRG_IMAP_PASSWORD
            UI_PASSWORD: $DMARC_SRG_UI_PASSWORD
        ports:
            - ${DMARC_SRG_HTTP_ADDRESS:-8082}:80
        restart: on-failure:2
```
