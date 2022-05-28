api_gen() {
    local request="$1"
    local api="$2"
    local json_path="$3"
    if curl -u "admin:stark" -X "${request}" "http://localhost:8081/service/rest/${api}" -H "accept: application/json" -H "Content-Type: application/json" -d "@${json_path}"; then
        "REPOSITORIES CREATE REPOSITORY :: Successfully created the repository - ${request}/${api} - ${json_path}"
    else
        "REPOSITORIES CREATE REPOSITORY :: Failed to create the repository - ${request}/${api} - ${json_path}"
    fi
}
api_gen "POST" "v1/security/users" "/test/jenkins-user.json"
