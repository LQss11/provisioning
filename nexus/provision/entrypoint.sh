NEXUS_URL="localhost:8081"
CREDENTIALS="admin:${NEXUS_ADMIN_PASSWORD}"

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
  "roles" : [ ]
}'
