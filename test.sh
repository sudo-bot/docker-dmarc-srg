#!/bin/sh

set -eu

DID_FAIL=0

checkUrl() {
    set +e
    if [ "${2:-}" = "form" ]; then
        curl -# --cookie-jar /tmp/test.cookie-jar -b /tmp/test.cookie-jar --fail \
        -s \
        -H 'Content-Type: application/json' \
        -L \
        --data-raw "${3}" \
        "$1"
    else
        curl -# --cookie-jar /tmp/test.cookie-jar -b /tmp/test.cookie-jar --fail \
            -s \
            ${2:-} \
            -H 'Content-Type: application/json' \
            "$1"
    fi

    if [ $? -gt 0 ]; then
        DID_FAIL=1
        echo "ERR: for URL ${1}"
    fi
    set -e
}

echo "Running tests..."

checkUrl "http://${TEST_ADDR}/" -I
checkUrl "http://${TEST_ADDR}/.nginx/status" -I
checkUrl "http://${TEST_ADDR}/.phpfpm/status" -I
checkUrl "http://${TEST_ADDR}/index.php"
checkUrl "http://${TEST_ADDR}/robots.txt" -I
checkUrl "http://${TEST_ADDR}/css/main.css" -I | grep -F "Cache-Control: max-age=315360000"

checkUrl "http://${TEST_ADDR}/index.php" | grep -q -F "DMARC Reports"
checkUrl "http://${TEST_ADDR}/login.php" "form" "{"password":"h9LoC5JRceynq5vRKeC4D2Bu7G7Fxny8yt4vCjQsp7vVE"}" | grep -q -F "Successfully logged into server."

if [ $DID_FAIL -gt 0 ]; then
    echo "Some URLs failed"
    exit 1
fi
