#!/bin/sh

set -eu

DID_FAIL=0

checkUrl() {
    set +e
    if [ "${2:-}" = "form" ]; then
        curl -# --cookie-jar /tmp/test.cookie-jar -b /tmp/test.cookie-jar --show-error --fail-with-body \
            -s \
            -H 'Accept: application/json' \
            -H 'Content-Type: application/json' \
            -L \
            --data-raw "${3}" \
            "$1"
    else
        curl -# --cookie-jar /tmp/test.cookie-jar -b /tmp/test.cookie-jar --show-error --fail-with-body \
            -s \
            ${2:-} \
            -H 'Content-Type: application/json' \
            "$1"
    fi
    set -e

    if [ $? -gt 0 ]; then
        echo "FAIL: ${1} ($?)"
        DID_FAIL=1
        return;
    fi
    echo "PASS: ${1}"
}

echo "Running tests..."

checkUrl "http://${TEST_ADDR}/"
checkUrl "http://${TEST_ADDR}/.nginx/status" -I
checkUrl "http://${TEST_ADDR}/index.php"
checkUrl "http://${TEST_ADDR}/robots.txt" -I
checkUrl "http://${TEST_ADDR}/css/main.css" -I | grep -F "Cache-Control: max-age=86400"

checkUrl "http://${TEST_ADDR}/index.php" | grep -q -F "DMARC Reports"
checkUrl "http://${TEST_ADDR}/login.php" "form" "{"password":"public"}" | grep -q -F "Successfully logged into server."

if [ $DID_FAIL -gt 0 ]; then
    echo "Some URLs failed"
    exit 1
fi
