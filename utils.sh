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
  STATUS="$$1"
  MSG="$2"
  DATE="$(date)"
  printf "[%s] %s - %s"  "${STATUS}" "${DATE}"  "${MSG}"
}

sys_log_trace()
{
  MSG="$1"
  sys_log_base "-" "${MSG}" 
}

sys_log_error()
{
  MSG="$1"
  sys_log_base "!" "${MSG}" 
}


