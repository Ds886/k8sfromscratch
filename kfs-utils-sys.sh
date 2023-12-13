#!/bin/sh


sc_ssh_wrapper()
{
  set +ue
  _SSH_WRAPPER_HOST_IP="$1"
  _SSH_WRAPPER_HOST_USER="$2"
  set +x
  _SSH_WRAPPER_HOST_PASS="$3"
  set -x
  _SSH_WRAPPER_CMD="$4"
  _SSH_WRAPPER_CMD_B64="$5"
  set +eu

  _SSH_WRAPPER_OPTS="-o StrictHostKeyChecking=no"
  _SSH_WRAPPER_EXIT_CODE=255

  # Make sure there is no expension confusion
  _SSH_WRAPPER_CMD_B64=$(echo "${_SSH_WRAPPER_CMD_B64}" | base64)

  sys_log_trace "Running command \"${_SSH_WRAPPER_CMD}\" on host \"${_SSH_WRAPPER_CMD}\" "
  set +x
  # shellcheck disable=2086
  sshpass -p "${_SSH_WRAPPER_HOST_PASS}" ssh ${_SSH_WRAPPER_OPTS} "${_SSH_WRAPPER_HOST_USER}@${_SSH_WRAPPER_HOST_IP}" "eval \"\$\(echo ${_SSH_WRAPPER_CMD_B64}|base64 -d\)"
  _SSH_WRAPPER_EXIT_CODE=$?
  set -x

  return $_SSH_WRAPPER_EXIT_CODE
}

sc_change_hostname()
{
  set +ue
  _CH_HOST_HOSTNAME=$1
  _CH_HOST_HOST_IP="$2"
  _CH_HOST_HOST_USER="$3"
  set +x
  _CH_HOST_HOST_PASS="$4"
  set -x
  set -ue

  _CH_HOST_IS_LOCAL="true"
  _CH_HOST_HOSTS_FILE=/etc/hosts

  # Possible failures to check:  
  # 1. path not accessible by the user
  # 2. redirection can autoexpand in some cases(should be resolved by base64ing it)
  # 3. add a precheck whether the host available
  # 4. should do keyscna though might lead to issues of it is changed on remote

  sys_log_trace "Changing hostname to ${_HOSTNAME}"
  # Detect if local
  if [ "${_CH_HOST_HOST_IP}" != "127.0.0.1" ]
  then
    _CH_HOST_IS_LOCAL="false"
  fi

  if [ "${_CH_HOST_HOST_IP}" != "localhost" ]
  then
    _CH_HOST_IS_LOCAL="false"
  fi

  sys_log_trace "Running remote is: ${_CH_HOST_IS_LOCAL}"
  if [ "${_CH_HOST_IS_LOCAL}" = "false" ]
  then
    _CH_HOST_HOSTS_FILE=./hosts-${_CH_HOST_HOSTNAME}
    sys_log_trace "Copying host file to:\"${_CH_HOST_HOSTS_FILE}\""
    sshpass -p "${_CH_HOST_HOST_PASS}"  scp "${_CH_HOST_HOST_USER}@${_CH_HOST_HOST_IP}:/etc/hosts" "${_CH_HOST_HOSTS_FILE}"
  fi

  sc_ssh_wrapper "${_CH_HOST_HOST_IP}" "${_CH_HOST_HOST_USER}" "${_CH_HOST_HOST_PASS}" "echo \"${_HOSTNAME}\" > /etc/hostname"

  sed "s/127.0.0.1       localhost localhost.localdomain/127.0.0.1       localhost localhost.localdomain ${_HOSTNAME}/g" > "${_CH_HOST_HOSTS_FILE}"
  sed "s/::1       localhost localhost.localdomain/::1       localhost localhost.localdomain ${_HOSTNAME}/g" > "${_CH_HOST_HOSTS_FILE}"

  if [ "${_CH_HOST_IS_LOCAL}" = "false" ]
  then
    sshpass -p "${_CH_HOST_HOST_PASS}" scp "${_CH_HOST_HOSTS_FILE}" "${_CH_HOST_HOST_USER}@${_CH_HOST_HOST_IP}:/etc/hosts"
  fi
}

sc_file_shipper()
{
  set +ue
  _FILE_SHIP_HOST_IP="$1"
  set +x
  _FILE_SHIP_HOST_PASS="$2"
  set -x
  _FILE_SHIP_PATH_LOCAL="$3"
  _FILE_SHIP_PATH_REMOTE="$4"
  set -ue

  sys_log_trace "Copying \"${_FILE_SHIP_PATH_LOCAL}\" to:\"${_FILE_SHIP_PATH_REMOTE}\""
  sshpass -p "${_FILE_SHIP_HOST_PASS}" scp "${_FILE_SHIP_PATH_LOCAL}" "${_FILE_SHIP_HOST_USER}@${_FILE_SHIP_HOST_IP}:${_FILE_SHIP_PATH_REMOTE}"
}
