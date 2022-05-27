NEXUS_URL="localhost:8081"
CREDENTIALS="admin:${NEXUS_ADMIN_PASSWORD}"

# Helper Functions
trap ctrl_c INT
ctrl_c() {
    exit 0
}

error_msg() {
    local msg="$1"
    echo -e "[ERROR] $(date) :: $msg"
    exit 1
}

log_msg() {
    local msg="$1"
    echo -e "[LOG] $(date) :: $msg"
}

wait_for_endpoints() {
    declare endpoints=($@)
    for endpoint in "${endpoints[@]}"; do
        counter=1
        while [[ $(curl -s -o /dev/null -w ''%{http_code}'' "$endpoint") != "200" ]]; do
            counter=$((counter + 1))
            log_msg "WAIT FOR ENDPOINTS :: Waiting for - ${endpoint}"
            if [[ $counter -gt 60 ]]; then
                error_msg "WAIT FOR ENDPOINTS :: Not healthy - ${endpoint}"
            fi
            sleep 3
        done
        log_msg "WAIT FOR ENDPOINTS :: Healthy endpoint - ${endpoint}"
    done
}

# Wait for Nexus to be healthy
wait_for_healthy_response() {
    wait_for_endpoints "${NEXUS_URL}/service/rest/v1/status/writable"
    log_msg "WAIT FOR HEALTHY RESPONSE :: Nexus API is ready to receive requests"
}
# Start Nexus
start_nexus() {
    /opt/sonatype/start-nexus-repository-manager.sh &
}

# Change initial admin password
change_initial_password() {
    if [[ -f "/nexus-data/admin.password" ]]; then
        INITIAL_PASSWORD="$(head -n 1 /nexus-data/admin.password)"
    else
        INITIAL_PASSWORD=${NEXUS_ADMIN_PASSWORD}
    fi
    curl -v \
        -u "admin:${INITIAL_PASSWORD}" \
        -X PUT "${NEXUS_URL}/service/rest/v1/security/users/admin/change-password" \
        -H "Content-Type: text/plain" \
        -d "${NEXUS_ADMIN_PASSWORD}"
}
enable_anonymous_access() {
    # Enable anonymous acces
    curl -X 'PUT' \
        "http://${NEXUS_URL}/service/rest/v1/security/anonymous" \
        -u "${CREDENTIALS}" \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d '{
  "enabled": true,
  "userId": "anonymous",
  "realmName": "NexusAuthorizingRealm"
}'
}
# Helm repo
create_helm_repo() {
    curl -X 'POST' \
        "http://${NEXUS_URL}/service/rest/v1/repositories/helm/hosted" \
        -u "${CREDENTIALS}" \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d '{
  "name": "helm",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true,
    "writePolicy": "allow_once"
  },
  "cleanup": {
    "policyNames": [
      "string"
    ]
  },
  "component": {
    "proprietaryComponents": true
  }
}'
}
# Helm role
create_helm_role() {
    curl -X 'POST' \
        "http://${NEXUS_URL}/service/rest/v1/security/roles" \
        -u "${CREDENTIALS}" \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d '{
  "id" : "helm-role",
  "source" : "default",
  "name" : "helm",
  "description" : "manage helm",
  "privileges" : [ "nx-repository-view-helm-*-*" ],
  "roles" : [ ]
}'
}
create_jenkins_user() {
    # Add jenkins user
    curl -X 'POST' \
        "http://${NEXUS_URL}/service/rest/v1/security/users" \
        -u "${CREDENTIALS}" \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d '{
  "userId" : "jenkins",
  "firstName" : "jenkins",
  "lastName" : "jenkins",
  "emailAddress" : "jenkins@jenkins.com",
  "password" : "jenkins",
  "status" : "active",
  "roles" : [ "helm-role" ]
}' 
}

main() {
    start_nexus
    wait_for_healthy_response
    change_initial_password
    enable_anonymous_access
    create_helm_role
    create_helm_repo
    create_jenkins_user
}

# Run
main

# Keeps Nexus running in the background
wait
