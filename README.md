# A Docker [DmarcSrg](https://github.com/liuch/dmarc-srg#readme) image

This image uses:

- Alpine as a base image (`webdevops/php-nginx:8.3-alpine`)
- Nginx as a web server with PHP-FPM

Tables will be prefixed with: `dmarc-srg_` by default.
And require a `${MAILBOX_NAME}` IMAP folder with unread reports.
That will be moved to `${MAILBOXES_WHEN_DONE_MOVE_TO}` or `${MAILBOXES_WHEN_FAILED_MOVE_TO}`.

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
- `USER_MANAGEMENT` optional: (A boolean to enable managing users from the Web UI)
- `DOMAIN_VERIFICATION` optional: (Domain ownership verification method for users who are authorized to add domains. Valid values: `dns` and `none`.)
- `MAILBOX_NAME` (The mailbox folder name where reports are stored to be ingested)
- `MAILBOXES_WHEN_DONE_MOVE_TO` (The mailbox folder name where reports are stored when they passed ingestion)
- `MAILBOXES_WHEN_FAILED_MOVE_TO` (The mailbox folder name where reports are stored when they failed ingestion)

#### For `utils/summary_report.php`

- `MAILER_FROM` (An email)
- `MAILER_DEFAULT` (An email)

## Usage

## Fetching reports

A cron is located in `/var/spool/cron/crontabs/application` and will fetch reports hourly.
Feel free to mount another [crontab file](./docker/crontab) to `/var/spool/cron/crontabs/application`
See: [cron setup from the upstream image](https://github.com/webdevops/Dockerfile/issues/280)

## Docker compose

```yml
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
            # Use "." or "/" to use sub-folders
            MAILBOX_NAME: DMARC
            MAILBOXES_WHEN_DONE_MOVE_TO: DMARC-PROCESSED.Aggregate
            MAILBOXES_WHEN_FAILED_MOVE_TO: DMARC-PROCESSED.Invalid
        ports:
            - ${DMARC_SRG_HTTP_ADDRESS:-8082}:80
        restart: on-failure:2
```
