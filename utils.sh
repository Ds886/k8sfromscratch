#!/bin/sh

sys_ensure_folder()
{
  FOLDER_NAME="$1"
  [ -z "${FOLDER_NAME}" ] && (echo "No parameter passed to ensure_folder" && exit 1)

  mkdir -p "${FOLDER_NAME}"
}

sys_ensure_folder_or_exit()
{
  FOLDER_NAME="$1"
  [ -z "${FOLDER_NAME}" ] && (echo "No parameter passed to ensure_folder" && exit 1)

  (sys_ensure_folder "$FOLDER_NAME" && cd "$FOLDER_NAME") || (echo "Failed to create folder $FOLDER_NAME" && exit 1)
}

sys_log_base()
{
  STATUS="$1"
  MSG="$2"
  DATE="$(date)"
  printf "[%b] %s - %s\n"  "${STATUS}" "${DATE}"  "${MSG}"
}

sys_log_trace()
{
  set +x
  MSG="$1"
  sys_log_base '-' "${MSG}"
  set -x
}

sys_log_error()
{
  set +x
  MSG="$1"
  sys_log_base "!" "${MSG}" 
  set -x
}


