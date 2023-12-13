#!/bin/sh
set -exu

. ./vars.sh
. ./utils.sh
. ./certs.sh
sys_log_trace "Imported libraries"


PACKAGES_INFRA="curl python3 cfssl kubectl"
TEMP_DIR=$(mktemp -d)

set -x
[ "${USER}" != "root" ] && sys_log_error "Script must be run as root" && exit 1
set +x



sys_log_trace "Changing repositories to edge"
echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" | tee /etc/apk/repositories
echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" | tee -a /etc/apk/repositories
echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" | tee -a /etc/apk/repositories

sys_log_trace "Installing ${PACKAGES_INFRA}"
# shellcheck disable=2086
apk update && apk upgrade && apk add ${PACKAGES_INFRA}

sc_change_hostname "${K8S_HOSTS_CONTR_NAME}"

# sc_cert_gen_all
