#!/bin/bash

function wait_for_and_test_endpoint {
    period=10
    limit=30
    looper=${limit}
    # wait for the app to be all hooked up and working
    url="$1"
    res=$(curl -XGET -s ${url} -H 'Content-Type: application/json' -H 'Cache-Control: no-cache')
    status=$(echo ${res} | jq '.status' || echo 'nada')
    while [[ "$status" != '"healthy"' ]]; do
        echo "url: $url; res: $res; status: $status"
        if [[ $(($looper+0)) == 0 ]]; then
            echo "URL: \"$url\" Response: \"$res\""
            echo "Timeout waiting for health of \"$url\" after $(($limit * $period)) seconds!"
            exit 1
        fi
        looper=$(($looper-1))
        echo "URL: \"$url\" Response: \"$res\" | Sleeping $period seconds [$(($limit-$looper))/$limit]"
        sleep ${period}
        res=$(curl -XGET -s ${url} -H 'Content-Type: application/json' -H 'Cache-Control: no-cache')
        status=$(echo ${res} | jq '.status' || echo 'nada')
    done
    echo "url: $url; res: $res; status: $status"
    if [[ ${status} == 'nada' || ${status} != '"healthy"' ]]; then
      echo "Test Fail: $url; Expected:'"healthy"'; Actual:$status"
      exit 1
    else
      echo "Test Pass: $1"
    fi
}

echo "SERVICE: $SERVICE"

wait_for_and_test_endpoint "$SERVICE/health/app/"
wait_for_and_test_endpoint "$SERVICE/health/database/"
wait_for_and_test_endpoint "$SERVICE/health/celery/"
wait_for_and_test_endpoint "$SERVICE/health/tickers-loaded/"
wait_for_and_test_endpoint "$SERVICE/health/quotes-updated/"
