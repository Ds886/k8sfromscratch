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

sc_change_hostname()
{
  _HOSTNAME=$1
  sys_log_trace "Changing hostname to ${_HOSTNAME}"
  echo "${_HOSTNAME}" > /etc/hostname
  sed "s/127.0.0.1       localhost localhost.localdomain/127.0.0.1       localhost localhost.localdomain ${_HOSTNAME}/g" > /etc/hosts
  sed "s/::1       localhost localhost.localdomain/::1       localhost localhost.localdomain ${_HOSTNAME}/g" > /etc/hosts
}

sc_cert_gen_all()
{
  sc_cert_gen_ca
  sc_cert_gen_admin
  sc_cert_gen_controller_manager
  sc_cert_gen_kube_proxy
  sc_cert_gen_scheduler
  sc_cert_gen_kubeapi "${K8S_EXTERNAL_IP}" "${K8S_HOST_NAME}"
  sc_cert_gen_serviceaccount

  sc_hosts_list=$(env |grep K8S_HOSTS|awk -F'_' '{print $3}'|sort| uniq| tr '\n' ' ')


  # shellcheck disable=2066
  for instance in ${sc_hosts_list} 
  do
    _CURR_HOST_NAME=$(eval "K8S_HOSTS_${instance}_NAME")
    _CURR_HOST_EXT_IP=$(eval "K8S_HOSTS_${instance}_EXTERNAL_IP")
    _CURR_HOST_INT_IP=$(eval "K8S_HOSTS_${instance}_INTERNAL_IP")

     sc_cert_gen_client "${_CURR_HOST_EXT_IP}" "${_CURR_HOST_INT_IP}" "${_CURR_HOST_NAME}"
  done
}

sys_log_trace "Changing repositories to edge"
echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" | tee /etc/apk/repositories
echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" | tee -a /etc/apk/repositories
echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" | tee -a /etc/apk/repositories

sys_log_trace "Installing ${PACKAGES_INFRA}"
# shellcheck disable=2086
apk update && apk upgrade && apk add ${PACKAGES_INFRA}

sc_change_hostname "${K8S_HOSTS_CONTR_NAME}"

# sc_cert_gen_all
