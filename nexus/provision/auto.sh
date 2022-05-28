#!/bin/bash

api_gen() {
    local request="$1"
    local api="$2"
    local filePath="$3"
    #echo curl -u 'admin:stark' -X ${request} "http://localhost:8081/service/rest/${api}" -H "accept: application/json" -H "Content-Type: application/json" -d "@${json}"
    # cat file | -d

    echo curl \
    -X "'${request}'" "'http://localhost:8081/service/rest/${api}'" \
    -H "'accept: application/json'" -H "'Content-Type: application/json'" \
    -u "'admin:stark'" \
    -d "'@${filePath}'"

}

# api=/v1/security/privileges....
# flags=""
#api_gen "api" "request-method" "json-path"

api_gen "POST" "v1/security/users" "/test/jenkins.json"
