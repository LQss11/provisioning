# Nexus provisioning
You can provision nexus in few steps without haing to worry aboout reconfiguring your env everytime and that's where provisioning comes!
# Quick start
in order to provision nexus on docker just run:
```sh
docker build -t nexus-provisioning .
docker run -d -p 8081:8081 -e NEXUS_ADMIN_PASSWORD=yourpass nexus-provisioning
```
by default on `Dockerfile` the default admin password is `admin`