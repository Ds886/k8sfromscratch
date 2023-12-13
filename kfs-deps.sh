#!/bin/sh

_DEPS_DEPS_RUNNER=ssh sshpass scp base64
_DEPS_DEPS_LIST="cfssl cfssljson python3 base64"
_DEPS_DEPS_OPTIONAL="curl"

deps_prepare_host()
{
  sys_log_trace "Changing repositories to edge"
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" | tee /etc/apk/repositories
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" | tee -a /etc/apk/repositories
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" | tee -a /etc/apk/repositories

  sys_log_trace "Installing ${PACKAGES_INFRA}"
  # shellcheck disable=2086
  apk update && apk upgrade && apk add ${PACKAGES_INFRA}

  sc_change_hostname "${K8S_HOSTS_CONTR_NAME}"
}

for DEP in $_DEPS_DEPS_LIST; do
  set +ue
  COMM=$(command -v "$DEP")
  if [ -z "${COMM}" ]; then
    sys_log_error "Command ${DEP} is not found"
    exit 1
  fi
  set -ue
done
