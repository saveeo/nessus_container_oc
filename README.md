# Nessus Containerization

## Starting

Build Containers from Container's folder.

### Main Container - Containerfile

`podman build --no-cache --platform linux/amd64 --build-arg NESSUS_RPM="Nessus-10.10.1-el9.x86_64.rpm" -t nessus-scanner_10.10.1:v0.1-x86_64 -f Containerfile`

`podman push --tls-verify=false <<BUILD_DIGEST_FROM_ABOVE>> quay.apps.ops.private.core42.systems/security/nessus/nessus-scanner_10.10.1:v0.1-x86_64`

### Build Init Container

`podman build --no-cache --platform linux/amd64 -t nessus-scanner-init_new_10.10.1:v0.1-x86_64 -f Containerfile.init`

`podman push --tls-verify=false <<BUILD_DIGEST_FROM_ABOVE>> quay.apps.ops.private.core42.systems/security/nessus/nessus-scanner-init_new_10.10.1:v0.1-x86_64`

### Deploy

Adjust the values in nessus-deployment-sts.yaml accrodingly and enjoy, ensure that you have already applied nessus-scc-roles.yaml to create necessary SCC and SA
