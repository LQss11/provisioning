
FROM sonatype/nexus3 
USER nexus
ENV NEXUS_ADMIN_PASSWORD="admin" 

COPY /provision /provision
CMD  /provision/entrypoint.sh
